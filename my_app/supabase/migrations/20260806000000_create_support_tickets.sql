-- Offline-first Help & Feedback storage and least-privilege access policies.

create table if not exists public.support_tickets (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  subject text not null check (char_length(btrim(subject)) between 1 and 160),
  status text not null default 'open'
    check (status in ('open', 'waiting_for_reply', 'resolved', 'closed')),
  priority text not null default 'normal'
    check (priority in ('low', 'normal', 'high', 'urgent')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.support_messages (
  id uuid primary key,
  ticket_id uuid not null references public.support_tickets(id) on delete cascade,
  sender_id uuid default auth.uid() references auth.users(id) on delete set null,
  sender_role text not null default 'user'
    check (sender_role in ('user', 'support')),
  body text not null check (char_length(btrim(body)) between 1 and 10000),
  attachment_path text,
  attachment_name text,
  attachment_type text,
  attachment_size bigint,
  created_at timestamptz not null default now(),
  constraint support_message_attachment_complete check (
    (attachment_path is null and attachment_name is null
      and attachment_type is null and attachment_size is null)
    or
    (attachment_path is not null and attachment_name is not null
      and attachment_type in ('image/jpeg', 'image/png', 'image/webp')
      and attachment_size between 1 and 10485760)
  )
);

create index if not exists support_tickets_user_updated_idx
on public.support_tickets(user_id, updated_at desc);
create index if not exists support_messages_ticket_created_idx
on public.support_messages(ticket_id, created_at);
create index if not exists support_messages_sender_id_idx
on public.support_messages(sender_id);

drop trigger if exists update_support_tickets_updated_at on public.support_tickets;
create trigger update_support_tickets_updated_at
before update on public.support_tickets
for each row execute function public.update_updated_at_column();

create or replace function public.touch_support_ticket()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.support_tickets set updated_at = now() where id = new.ticket_id;
  return new;
end;
$$;

drop trigger if exists touch_support_ticket_after_message on public.support_messages;
create trigger touch_support_ticket_after_message
after insert on public.support_messages
for each row execute function public.touch_support_ticket();

revoke all on function public.touch_support_ticket() from public;

alter table public.support_tickets enable row level security;
alter table public.support_messages enable row level security;

revoke all on public.support_tickets, public.support_messages from anon;
grant select, insert, update on public.support_tickets to authenticated;
grant select, insert on public.support_messages to authenticated;

drop policy if exists support_tickets_select_owner_or_admin on public.support_tickets;
create policy support_tickets_select_owner_or_admin
on public.support_tickets for select to authenticated
using (
  user_id = (select auth.uid())
  or (select private.is_admin((select auth.uid())))
);

drop policy if exists support_tickets_insert_owner on public.support_tickets;
create policy support_tickets_insert_owner
on public.support_tickets for insert to authenticated
with check (
  user_id = (select auth.uid())
  and status = 'open'
  and priority = 'normal'
);

drop policy if exists support_tickets_update_admin on public.support_tickets;
create policy support_tickets_update_admin
on public.support_tickets for update to authenticated
using ((select private.is_admin((select auth.uid()))))
with check ((select private.is_admin((select auth.uid()))));

drop policy if exists support_messages_select_ticket_participant on public.support_messages;
create policy support_messages_select_ticket_participant
on public.support_messages for select to authenticated
using (
  exists (
    select 1 from public.support_tickets
    where support_tickets.id = support_messages.ticket_id
      and support_tickets.user_id = (select auth.uid())
  )
  or (select private.is_admin((select auth.uid())))
);

drop policy if exists support_messages_insert_owner on public.support_messages;
create policy support_messages_insert_owner
on public.support_messages for insert to authenticated
with check (
  sender_id = (select auth.uid())
  and sender_role = 'user'
  and exists (
    select 1 from public.support_tickets
    where support_tickets.id = support_messages.ticket_id
      and support_tickets.user_id = (select auth.uid())
      and support_tickets.status <> 'closed'
  )
);

drop policy if exists support_messages_insert_admin on public.support_messages;
create policy support_messages_insert_admin
on public.support_messages for insert to authenticated
with check (
  sender_id = (select auth.uid())
  and sender_role = 'support'
  and (select private.is_admin((select auth.uid())))
);

create or replace function public.support_close_ticket(p_ticket_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  update public.support_tickets
  set status = 'closed'
  where id = p_ticket_id and user_id = (select auth.uid());

  if not found then
    raise exception 'Ticket not found' using errcode = 'P0002';
  end if;
end;
$$;

revoke all on function public.support_close_ticket(uuid) from public;
grant execute on function public.support_close_ticket(uuid) to authenticated;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'support-attachments',
  'support-attachments',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists support_attachment_read on storage.objects;
create policy support_attachment_read
on storage.objects for select to authenticated
using (
  bucket_id = 'support-attachments'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or (select private.is_admin((select auth.uid())))
  )
);

drop policy if exists support_attachment_insert_owner on storage.objects;
create policy support_attachment_insert_owner
on storage.objects for insert to authenticated
with check (
  bucket_id = 'support-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists support_attachment_update_owner on storage.objects;
create policy support_attachment_update_owner
on storage.objects for update to authenticated
using (
  bucket_id = 'support-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'support-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists support_attachment_manage_admin on storage.objects;
create policy support_attachment_manage_admin
on storage.objects for all to authenticated
using (
  bucket_id = 'support-attachments'
  and (select private.is_admin((select auth.uid())))
)
with check (
  bucket_id = 'support-attachments'
  and (select private.is_admin((select auth.uid())))
);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'support_tickets'
  ) then
    alter publication supabase_realtime add table public.support_tickets;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'support_messages'
  ) then
    alter publication supabase_realtime add table public.support_messages;
  end if;
end $$;
