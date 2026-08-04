-- Restore the ownership boundary if an earlier development migration was run. Not migrate it
create or replace function public.sync_reorder_songs(
  p_column_id uuid,
  p_song_ids uuid[]
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  requested_count integer := coalesce(cardinality(p_song_ids), 0);
  owned_count integer;
  distinct_count integer;
begin
  if p_column_id is null or requested_count = 0 then
    raise exception 'Column and song IDs are required' using errcode = '22023';
  end if;

  select count(distinct song_id)
  into distinct_count
  from unnest(p_song_ids) as requested(song_id);

  if distinct_count <> requested_count then
    raise exception 'Song IDs must be unique' using errcode = '22023';
  end if;

  select count(*)
  into owned_count
  from public.songs
  where column_id = p_column_id
    and created_by = (select auth.uid())
    and not deleted;

  if owned_count <> requested_count or exists (
    select 1
    from unnest(p_song_ids) as requested(song_id)
    left join public.songs on songs.id = requested.song_id
      and songs.column_id = p_column_id
      and songs.created_by = (select auth.uid())
      and not songs.deleted
    where songs.id is null
  ) then
    raise exception 'Cannot reorder songs you do not own'
      using errcode = '42501';
  end if;

  update public.songs
  set position = (requested.position - 1)::integer
  from unnest(p_song_ids) with ordinality as requested(song_id, position)
  where songs.id = requested.song_id
    and songs.column_id = p_column_id
    and songs.created_by = (select auth.uid());
end;
$$;

revoke all on function public.sync_reorder_songs(uuid, uuid[]) from public;
grant execute on function public.sync_reorder_songs(uuid, uuid[]) to authenticated;
