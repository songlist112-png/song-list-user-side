-- Private attachment storage.
-- User object path must be: {auth.uid()}/{song_id}/{file_name}

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'attachments',
  'attachments',
  false,
  52428800,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'image/jpeg',
    'image/png'
  ]
)
on conflict (id) do nothing;

drop policy if exists "attachment_files_read" on storage.objects;
create policy "attachment_files_read"
on storage.objects for select to authenticated
using (
  bucket_id = 'attachments'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or exists (
      select 1
      from public.attachments
      join public.songs on songs.id = attachments.song_id
      where attachments.file_url = storage.objects.name
        and not attachments.deleted
        and (select private.is_admin(songs.created_by))
    )
  )
);

drop policy if exists "attachment_files_insert_owner" on storage.objects;
create policy "attachment_files_insert_owner"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "attachment_files_update_owner" on storage.objects;
create policy "attachment_files_update_owner"
on storage.objects for update to authenticated
using (
  bucket_id = 'attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "attachment_files_delete_owner" on storage.objects;
create policy "attachment_files_delete_owner"
on storage.objects for delete to authenticated
using (
  bucket_id = 'attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "attachment_files_manage_admin" on storage.objects;
create policy "attachment_files_manage_admin"
on storage.objects for all to authenticated
using (
  bucket_id = 'attachments'
  and (select private.is_admin((select auth.uid())))
)
with check (
  bucket_id = 'attachments'
  and (select private.is_admin((select auth.uid())))
);
