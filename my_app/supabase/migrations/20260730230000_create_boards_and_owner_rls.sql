-- Extends the existing created_by-based schema without renaming tables/columns.
-- Existing admin/song-manager policies remain authoritative.
-- Added owner policies let normal users manage only content they create.

alter table public.boards
add column if not exists show_artist boolean not null default true,
add column if not exists show_bpm boolean not null default false,
add column if not exists dark_mode boolean not null default false;

create index if not exists boards_created_by_idx
on public.boards(created_by);
create index if not exists columns_board_id_idx
on public.columns(board_id);
create index if not exists columns_created_by_idx
on public.columns(created_by);
create index if not exists songs_column_id_idx
on public.songs(column_id);
create index if not exists songs_created_by_idx
on public.songs(created_by);
create index if not exists attachments_song_id_idx
on public.attachments(song_id);
create index if not exists labels_created_by_idx
on public.labels(created_by);
create index if not exists artists_created_by_idx
on public.artists(created_by);
create index if not exists song_labels_song_id_idx
on public.song_labels(song_id);
create index if not exists song_labels_label_id_idx
on public.song_labels(label_id);
create index if not exists song_artists_song_id_idx
on public.song_artists(song_id);
create index if not exists song_artists_artist_id_idx
on public.song_artists(artist_id);

drop trigger if exists update_boards_updated_at on public.boards;
create trigger update_boards_updated_at
before update on public.boards
for each row execute function public.update_updated_at_column();

drop trigger if exists update_columns_updated_at on public.columns;
create trigger update_columns_updated_at
before update on public.columns
for each row execute function public.update_updated_at_column();

alter table public.boards enable row level security;
alter table public.columns enable row level security;
alter table public.songs enable row level security;
alter table public.labels enable row level security;
alter table public.artists enable row level security;
alter table public.song_labels enable row level security;
alter table public.song_artists enable row level security;
alter table public.attachments enable row level security;

drop policy if exists "boards_select_authenticated" on public.boards;
create policy "boards_select_authenticated"
on public.boards for select to authenticated
using (
  created_by = (select auth.uid())
  or (select private.is_admin(created_by))
);

drop policy if exists "columns_select_authenticated" on public.columns;
create policy "columns_select_authenticated"
on public.columns for select to authenticated
using (
  created_by = (select auth.uid())
  or exists (
    select 1 from public.boards
    where boards.id = board_id
      and (select private.is_admin(boards.created_by))
  )
);

drop policy if exists "songs_select_authenticated" on public.songs;
create policy "songs_select_authenticated"
on public.songs for select to authenticated
using (
  not deleted
  and (
    created_by = (select auth.uid())
    or (select private.is_admin(created_by))
  )
);

drop policy if exists "labels_select_authenticated" on public.labels;
create policy "labels_select_authenticated"
on public.labels for select to authenticated
using (
  created_by = (select auth.uid())
  or (select private.is_admin(created_by))
);

drop policy if exists "artists_select_authenticated" on public.artists;
create policy "artists_select_authenticated"
on public.artists for select to authenticated
using (
  created_by = (select auth.uid())
  or (select private.is_admin(created_by))
);

drop policy if exists "attachments_select_authenticated"
on public.attachments;
create policy "attachments_select_authenticated"
on public.attachments for select to authenticated
using (
  not deleted
  and exists (
    select 1 from public.songs
    where songs.id = song_id
      and not songs.deleted
  )
);

drop policy if exists "song_labels_select_authenticated"
on public.song_labels;
create policy "song_labels_select_authenticated"
on public.song_labels for select to authenticated
using (exists (select 1 from public.songs where songs.id = song_id));

drop policy if exists "song_artists_select_authenticated"
on public.song_artists;
create policy "song_artists_select_authenticated"
on public.song_artists for select to authenticated
using (exists (select 1 from public.songs where songs.id = song_id));

drop policy if exists "boards_insert_owner" on public.boards;
drop policy if exists "boards_update_owner" on public.boards;
drop policy if exists "boards_delete_owner" on public.boards;

create policy "boards_insert_owner"
on public.boards for insert to authenticated
with check (created_by = (select auth.uid()));

create policy "boards_update_owner"
on public.boards for update to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

create policy "boards_delete_owner"
on public.boards for delete to authenticated
using (created_by = (select auth.uid()));

drop policy if exists "columns_insert_owner" on public.columns;
drop policy if exists "columns_update_owner" on public.columns;
drop policy if exists "columns_delete_owner" on public.columns;

create policy "columns_insert_owner"
on public.columns for insert to authenticated
with check (
  created_by = (select auth.uid())
  and exists (
    select 1 from public.boards
    where boards.id = board_id
      and boards.created_by = (select auth.uid())
  )
);

create policy "columns_update_owner"
on public.columns for update to authenticated
using (created_by = (select auth.uid()))
with check (
  created_by = (select auth.uid())
  and exists (
    select 1 from public.boards
    where boards.id = board_id
      and boards.created_by = (select auth.uid())
  )
);

create policy "columns_delete_owner"
on public.columns for delete to authenticated
using (created_by = (select auth.uid()));

drop policy if exists "songs_insert_owner" on public.songs;
drop policy if exists "songs_update_owner" on public.songs;
drop policy if exists "songs_delete_owner" on public.songs;

create policy "songs_insert_owner"
on public.songs for insert to authenticated
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

create policy "songs_update_owner"
on public.songs for update to authenticated
using (created_by = (select auth.uid()))
with check (
  created_by = (select auth.uid())
  and not is_published
  and exists (
    select 1
    from public.columns
    join public.boards on boards.id = columns.board_id
    where columns.id = songs.column_id
      and columns.created_by = (select auth.uid())
      and boards.created_by = (select auth.uid())
  )
);

create policy "songs_delete_owner"
on public.songs for delete to authenticated
using (created_by = (select auth.uid()));

drop policy if exists "labels_insert_owner" on public.labels;
drop policy if exists "labels_update_owner" on public.labels;
drop policy if exists "labels_delete_owner" on public.labels;

create policy "labels_insert_owner"
on public.labels for insert to authenticated
with check (created_by = (select auth.uid()));

create policy "labels_update_owner"
on public.labels for update to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

create policy "labels_delete_owner"
on public.labels for delete to authenticated
using (created_by = (select auth.uid()));

drop policy if exists "artists_insert_owner" on public.artists;
drop policy if exists "artists_update_owner" on public.artists;
drop policy if exists "artists_delete_owner" on public.artists;

create policy "artists_insert_owner"
on public.artists for insert to authenticated
with check (created_by = (select auth.uid()));

create policy "artists_update_owner"
on public.artists for update to authenticated
using (created_by = (select auth.uid()))
with check (created_by = (select auth.uid()));

create policy "artists_delete_owner"
on public.artists for delete to authenticated
using (created_by = (select auth.uid()));

drop policy if exists "song_labels_insert_owner" on public.song_labels;
drop policy if exists "song_labels_update_owner" on public.song_labels;
drop policy if exists "song_labels_delete_owner" on public.song_labels;

create policy "song_labels_insert_owner"
on public.song_labels for insert to authenticated
with check (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);

create policy "song_labels_update_owner"
on public.song_labels for update to authenticated
using (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);

create policy "song_labels_delete_owner"
on public.song_labels for delete to authenticated
using (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);

drop policy if exists "song_artists_insert_owner" on public.song_artists;
drop policy if exists "song_artists_update_owner" on public.song_artists;
drop policy if exists "song_artists_delete_owner" on public.song_artists;

create policy "song_artists_insert_owner"
on public.song_artists for insert to authenticated
with check (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);

create policy "song_artists_update_owner"
on public.song_artists for update to authenticated
using (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);

create policy "song_artists_delete_owner"
on public.song_artists for delete to authenticated
using (
  exists (
    select 1 from public.songs
    where songs.id = song_id
      and songs.created_by = (select auth.uid())
  )
);
