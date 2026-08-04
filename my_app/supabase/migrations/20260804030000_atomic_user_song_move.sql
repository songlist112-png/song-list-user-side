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

  if not exists (
    select 1
    from public.songs
    where id = p_song_id
      and column_id = p_source_column_id
      and created_by = (select auth.uid())
      and not deleted
  ) then
    raise exception 'Cannot move a song you do not own'
      using errcode = '42501';
  end if;

  if cardinality(p_source_song_ids) <> coalesce(
    cardinality(array(select distinct unnest(p_source_song_ids))),
    0
  ) or cardinality(p_destination_song_ids) <> coalesce(
    cardinality(array(select distinct unnest(p_destination_song_ids))),
    0
  ) then
    raise exception 'Song IDs must be unique' using errcode = '22023';
  end if;

  select count(*) into v_source_count
  from public.songs
  where column_id = p_source_column_id
    and created_by = (select auth.uid())
    and not deleted;

  select count(*) into v_destination_count
  from public.songs
  where column_id = p_destination_column_id
    and created_by = (select auth.uid())
    and not deleted;

  if coalesce(cardinality(p_source_song_ids), 0) <> v_source_count - 1
      or coalesce(cardinality(p_destination_song_ids), 0) <> v_destination_count + 1
      or not p_song_id = any(p_destination_song_ids)
      or p_song_id = any(p_source_song_ids)
      or exists (
        select 1
        from public.songs
        where column_id = p_source_column_id
          and created_by = (select auth.uid())
          and not deleted
          and id <> p_song_id
          and not id = any(p_source_song_ids)
      )
      or exists (
        select 1
        from unnest(p_source_song_ids) as requested(song_id)
        left join public.songs on songs.id = requested.song_id
          and songs.column_id = p_source_column_id
          and songs.created_by = (select auth.uid())
          and not songs.deleted
        where songs.id is null
      )
      or exists (
        select 1
        from public.songs
        where column_id = p_destination_column_id
          and created_by = (select auth.uid())
          and not deleted
          and not id = any(p_destination_song_ids)
      )
      or exists (
        select 1
        from unnest(p_destination_song_ids) as requested(song_id)
        left join public.songs on songs.id = requested.song_id
          and songs.column_id = p_destination_column_id
          and songs.created_by = (select auth.uid())
          and not songs.deleted
        where requested.song_id <> p_song_id and songs.id is null
      ) then
    raise exception 'Move order does not match your current songs'
      using errcode = '22023';
  end if;

  update public.songs
  set column_id = p_destination_column_id
  where id = p_song_id
    and created_by = (select auth.uid());

  update public.songs
  set position = requested.position - 1
  from unnest(p_source_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_source_column_id
    and songs.created_by = (select auth.uid());

  update public.songs
  set position = requested.position - 1
  from unnest(p_destination_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_destination_column_id
    and songs.created_by = (select auth.uid());
end;
$$;

revoke all on function public.sync_move_song(uuid, uuid, uuid, uuid[], uuid[]) from public;
grant execute on function public.sync_move_song(uuid, uuid, uuid, uuid[], uuid[]) to authenticated;
