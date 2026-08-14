-- Reorder every user-owned song in one transaction and return canonical order.
-- The caller deletes its offline queue row only when this exact array matches.
drop function if exists public.sync_reorder_songs(uuid, uuid[]);

create function public.sync_reorder_songs(
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

  -- Serialize concurrent reorder requests for this user's column.
  perform 1
  from public.songs
  where column_id = p_column_id
    and created_by = (select auth.uid())
    and not deleted
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
    and songs.created_by = (select auth.uid());

  select array_agg(songs.id order by songs.position)
  into v_confirmed_song_ids
  from public.songs
  where songs.column_id = p_column_id
    and songs.created_by = (select auth.uid())
    and not songs.deleted;

  return coalesce(v_confirmed_song_ids, '{}'::uuid[]);
end;
$$;

revoke all on function public.sync_reorder_songs(uuid, uuid[]) from public;
grant execute on function public.sync_reorder_songs(uuid, uuid[]) to authenticated;
