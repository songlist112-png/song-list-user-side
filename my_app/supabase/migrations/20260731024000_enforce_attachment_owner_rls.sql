-- Attachment ownership follows its parent song.
-- Existing admin and published-read policies remain unchanged.

alter table public.attachments enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete
on table public.attachments
to authenticated;

drop policy if exists "attachments_owner_manage" on public.attachments;
create policy "attachments_owner_manage"
on public.attachments for all to authenticated
using (
  exists (
    select 1
    from public.songs
    where songs.id = attachments.song_id
      and songs.created_by = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.songs
    where songs.id = attachments.song_id
      and songs.created_by = (select auth.uid())
  )
);
