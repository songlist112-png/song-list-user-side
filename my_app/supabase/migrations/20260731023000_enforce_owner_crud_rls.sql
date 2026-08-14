-- Users may manage only content they created.
-- Existing admin/read policies remain unchanged.

alter table public.boards enable row level security;
alter table public.columns enable row level security;
alter table public.songs enable row level security;
alter table public.labels enable row level security;
alter table public.artists enable row level security;
alter table public.song_labels enable row level security;
alter table public.song_artists enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete
on table
  public.boards,
  public.columns,
  public.songs,
  public.labels,
  public.artists,
  public.song_labels,
  public.song_artists
to authenticated;

drop policy if exists "boards_insert_owner" on public.boards;
drop policy if exists "boards_update_owner" on public.boards;
drop policy if exists "boards_delete_owner" on public.boards;
drop policy if exists "boards_owner_manage" on public.boards;
create policy "boards_owner_manage"
on public.boards for all to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

drop policy if exists "columns_insert_owner" on public.columns;
drop policy if exists "columns_update_owner" on public.columns;
drop policy if exists "columns_delete_owner" on public.columns;
drop policy if exists "columns_owner_manage" on public.columns;
create policy "columns_owner_manage"
on public.columns for all to authenticated
using (created_by = (select auth.uid()))
with check (
  created_by = (select auth.uid())
  and exists (
    select 1
    from public.boards
    where boards.id = columns.board_id
      and boards.created_by = (select auth.uid())
  )
);

drop policy if exists "songs_insert_owner" on public.songs;
drop policy if exists "songs_update_owner" on public.songs;
drop policy if exists "songs_delete_owner" on public.songs;
drop policy if exists "songs_owner_manage" on public.songs;
create policy "songs_owner_manage"
on public.songs for all to authenticated
using (created_by = (select auth.uid()))
with check (
  created_by = (select auth.uid())
  and not is_published
  and not deleted
  and exists (
    select 1
    from public.columns
    join public.boards on boards.id = columns.board_id
    where columns.id = songs.column_id
      and columns.created_by = (select auth.uid())
      and boards.created_by = (select auth.uid())
  )
);

drop policy if exists "labels_insert_owner" on public.labels;
drop policy if exists "labels_update_owner" on public.labels;
drop policy if exists "labels_delete_owner" on public.labels;
drop policy if exists "labels_owner_manage" on public.labels;
create policy "labels_owner_manage"
on public.labels for all to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

drop policy if exists "artists_insert_owner" on public.artists;
drop policy if exists "artists_update_owner" on public.artists;
drop policy if exists "artists_delete_owner" on public.artists;
drop policy if exists "artists_owner_manage" on public.artists;
create policy "artists_owner_manage"
on public.artists for all to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

drop policy if exists "song_labels_insert_owner" on public.song_labels;
drop policy if exists "song_labels_update_owner" on public.song_labels;
drop policy if exists "song_labels_delete_owner" on public.song_labels;
drop policy if exists "song_labels_owner_manage" on public.song_labels;
create policy "song_labels_owner_manage"
on public.song_labels for all to authenticated
using (
  exists (
    select 1
    from public.songs
    where songs.id = song_labels.song_id
      and songs.created_by = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.songs
    where songs.id = song_labels.song_id
      and songs.created_by = (select auth.uid())
  )
);

drop policy if exists "song_artists_insert_owner" on public.song_artists;
drop policy if exists "song_artists_update_owner" on public.song_artists;
drop policy if exists "song_artists_delete_owner" on public.song_artists;
drop policy if exists "song_artists_owner_manage" on public.song_artists;
create policy "song_artists_owner_manage"
on public.song_artists for all to authenticated
using (
  exists (
    select 1
    from public.songs
    where songs.id = song_artists.song_id
      and songs.created_by = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.songs
    where songs.id = song_artists.song_id
      and songs.created_by = (select auth.uid())
  )
);
