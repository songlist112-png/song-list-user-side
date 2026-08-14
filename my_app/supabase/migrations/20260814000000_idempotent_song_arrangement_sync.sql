-- Keep offline song arrangement uploads atomic and safe to retry.
-- These functions update only arrangement columns; song metadata is preserved.

create or replace function public.sync_reorder_songs(
  p_column_id uuid,
  p_song_ids uuid[]
)
returns uuid[]
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_requested_count integer := coalesce(cardinality(p_song_ids), 0);
  v_owned_count integer;
  v_distinct_count integer;
  v_confirmed_song_ids uuid[];
begin
  if p_column_id is null or v_requested_count = 0 then
    raise exception 'Column and song IDs are required' using errcode = '22023';
  end if;

  perform columns.id
  from public.columns
  join public.boards on boards.id = columns.board_id
  where columns.id = p_column_id
    and columns.created_by = (select auth.uid())
    and boards.created_by = (select auth.uid())
    and not columns.deleted
    and not boards.deleted
  for update of columns;

  if not found then
    raise exception 'Cannot reorder songs outside your board'
      using errcode = '42501';
  end if;

  -- Serialize arrangement changes for this user and column. Ordering the locks
  -- by primary key keeps concurrent operations from taking them inconsistently.
  perform 1
  from public.songs
  where column_id = p_column_id
    and created_by = (select auth.uid())
    and not deleted
  order by id
  for update;

  select count(distinct requested.song_id)
  into v_distinct_count
  from unnest(p_song_ids) as requested(song_id);

  if v_distinct_count <> v_requested_count then
    raise exception 'Song IDs must be unique' using errcode = '22023';
  end if;

  select count(*)
  into v_owned_count
  from public.songs
  where column_id = p_column_id
    and created_by = (select auth.uid())
    and not deleted;

  if v_owned_count <> v_requested_count or exists (
    select 1
    from unnest(p_song_ids) as requested(song_id)
    left join public.songs on songs.id = requested.song_id
      and songs.column_id = p_column_id
      and songs.created_by = (select auth.uid())
      and not songs.deleted
    where songs.id is null
  ) then
    raise exception 'Cannot reorder songs you do not own' using errcode = '42501';
  end if;

  update public.songs
  set position = requested.position - 1
  from unnest(p_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_column_id
    and songs.created_by = (select auth.uid())
    and songs.position is distinct from requested.position - 1;

  select array_agg(songs.id order by songs.position, songs.id)
  into v_confirmed_song_ids
  from public.songs
  where songs.column_id = p_column_id
    and songs.created_by = (select auth.uid())
    and not songs.deleted;

  return coalesce(v_confirmed_song_ids, '{}'::uuid[]);
end;
$$;

create or replace function public.sync_move_song(
  p_song_id uuid,
  p_source_column_id uuid,
  p_destination_column_id uuid,
  p_source_song_ids uuid[],
  p_destination_song_ids uuid[]
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_board_id uuid;
  v_current_column_id uuid;
  v_current_source_ids uuid[];
  v_current_destination_ids uuid[];
  v_source_count integer;
  v_destination_count integer;
begin
  if p_song_id is null
      or p_source_column_id is null
      or p_destination_column_id is null
      or p_source_song_ids is null
      or p_destination_song_ids is null
      or p_source_column_id = p_destination_column_id then
    raise exception 'Song and two different columns are required'
      using errcode = '22023';
  end if;

  if cardinality(p_source_song_ids) <> coalesce(
    cardinality(array(select distinct unnest(p_source_song_ids))),
    0
  ) or cardinality(p_destination_song_ids) <> coalesce(
    cardinality(array(select distinct unnest(p_destination_song_ids))),
    0
  ) or not p_song_id = any(p_destination_song_ids)
      or p_song_id = any(p_source_song_ids) then
    raise exception 'Move song IDs are invalid' using errcode = '22023';
  end if;

  select source_column.board_id
  into v_board_id
  from public.columns as source_column
  join public.columns as destination_column
    on destination_column.id = p_destination_column_id
   and destination_column.board_id = source_column.board_id
  join public.boards
    on boards.id = source_column.board_id
   and boards.created_by = (select auth.uid())
   and not boards.deleted
  where source_column.id = p_source_column_id
    and not source_column.deleted
    and not destination_column.deleted;

  if v_board_id is null then
    raise exception 'Cannot move songs outside your board'
      using errcode = '42501';
  end if;

  -- Column locks also serialize moves involving an empty source/destination.
  perform columns.id
  from public.columns
  where columns.id in (p_source_column_id, p_destination_column_id)
  order by columns.id
  for update;

  -- Lock both affected song sets before reading canonical arrangements.
  perform 1
  from public.songs
  where column_id in (p_source_column_id, p_destination_column_id)
    and created_by = (select auth.uid())
    and not deleted
  order by id
  for update;

  select songs.column_id
  into v_current_column_id
  from public.songs
  where songs.id = p_song_id
    and songs.created_by = (select auth.uid())
    and not songs.deleted;

  select coalesce(array_agg(songs.id order by songs.position, songs.id), '{}'::uuid[])
  into v_current_source_ids
  from public.songs
  where songs.column_id = p_source_column_id
    and songs.created_by = (select auth.uid())
    and not songs.deleted;

  select coalesce(array_agg(songs.id order by songs.position, songs.id), '{}'::uuid[])
  into v_current_destination_ids
  from public.songs
  where songs.column_id = p_destination_column_id
    and songs.created_by = (select auth.uid())
    and not songs.deleted;

  -- A committed request can be retried when the client loses the response.
  -- Treat an exact canonical match as success instead of leaving the queue stuck.
  if v_current_column_id = p_destination_column_id
      and v_current_source_ids = p_source_song_ids
      and v_current_destination_ids = p_destination_song_ids then
    return;
  end if;

  if v_current_column_id is distinct from p_source_column_id then
    raise exception 'Cannot move a song you do not own or that already moved'
      using errcode = '42501';
  end if;

  v_source_count := cardinality(v_current_source_ids);
  v_destination_count := cardinality(v_current_destination_ids);

  if cardinality(p_source_song_ids) <> v_source_count - 1
      or cardinality(p_destination_song_ids) <> v_destination_count + 1
      or exists (
        select 1
        from unnest(v_current_source_ids) as current_song(song_id)
        where current_song.song_id <> p_song_id
          and not current_song.song_id = any(p_source_song_ids)
      )
      or exists (
        select 1
        from unnest(p_source_song_ids) as requested(song_id)
        where not requested.song_id = any(v_current_source_ids)
      )
      or exists (
        select 1
        from unnest(v_current_destination_ids) as current_song(song_id)
        where not current_song.song_id = any(p_destination_song_ids)
      )
      or exists (
        select 1
        from unnest(p_destination_song_ids) as requested(song_id)
        where requested.song_id <> p_song_id
          and not requested.song_id = any(v_current_destination_ids)
      ) then
    raise exception 'Move order does not match your current songs'
      using errcode = '22023';
  end if;

  update public.songs
  set column_id = p_destination_column_id
  where id = p_song_id
    and created_by = (select auth.uid())
    and column_id = p_source_column_id;

  update public.songs
  set position = requested.position - 1
  from unnest(p_source_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_source_column_id
    and songs.created_by = (select auth.uid())
    and songs.position is distinct from requested.position - 1;

  update public.songs
  set position = requested.position - 1
  from unnest(p_destination_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_destination_column_id
    and songs.created_by = (select auth.uid())
    and songs.position is distinct from requested.position - 1;
end;
$$;

revoke all on function public.sync_reorder_songs(uuid, uuid[]) from public;
grant execute on function public.sync_reorder_songs(uuid, uuid[]) to authenticated;

revoke all on function public.sync_move_song(uuid, uuid, uuid, uuid[], uuid[]) from public;
grant execute on function public.sync_move_song(uuid, uuid, uuid, uuid[], uuid[]) to authenticated;
