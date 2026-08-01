-- Durable incremental-sync support. Apply before releasing offline clients.

alter table public.boards add column if not exists deleted boolean not null default false;
alter table public.columns add column if not exists deleted boolean not null default false;
alter table public.labels add column if not exists deleted boolean not null default false;
alter table public.artists add column if not exists deleted boolean not null default false;

alter table public.boards add column if not exists updated_at timestamptz not null default now();
alter table public.columns add column if not exists updated_at timestamptz not null default now();
alter table public.labels add column if not exists updated_at timestamptz not null default now();
alter table public.artists add column if not exists updated_at timestamptz not null default now();

create index if not exists boards_sync_idx on public.boards(updated_at, deleted);
create index if not exists columns_sync_idx on public.columns(updated_at, deleted);
create index if not exists songs_sync_idx on public.songs(updated_at, deleted);
create index if not exists labels_sync_idx on public.labels(updated_at, deleted);
create index if not exists artists_sync_idx on public.artists(updated_at, deleted);
create index if not exists attachments_sync_idx on public.attachments(updated_at, deleted);

do $$
declare table_name text;
begin
  foreach table_name in array array['boards', 'columns', 'labels', 'artists'] loop
    execute format('drop trigger if exists update_%I_updated_at on public.%I', table_name, table_name);
    execute format(
      'create trigger update_%I_updated_at before update on public.%I '
      'for each row execute function public.update_updated_at_column()',
      table_name,
      table_name
    );
  end loop;
end $$;

create table if not exists public.sync_tombstones (
  id bigint generated always as identity primary key,
  entity_type text not null,
  entity_id uuid not null,
  deleted_at timestamptz not null default now()
);
create index if not exists sync_tombstones_deleted_at_idx
on public.sync_tombstones(deleted_at);
alter table public.sync_tombstones enable row level security;
revoke all on public.sync_tombstones from anon, authenticated;

create or replace function public.capture_sync_tombstone()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.sync_tombstones(entity_type, entity_id)
  values (tg_table_name, old.id);
  return old;
end;
$$;

do $$
declare table_name text;
begin
  foreach table_name in array array['boards', 'columns', 'songs', 'labels', 'artists', 'attachments'] loop
    execute format('drop trigger if exists capture_%I_tombstone on public.%I', table_name, table_name);
    execute format(
      'create trigger capture_%I_tombstone after delete on public.%I '
      'for each row execute function public.capture_sync_tombstone()',
      table_name,
      table_name
    );
  end loop;
end $$;

create or replace function public.sync_server_time()
returns text
language sql
stable
security invoker
set search_path = public
as $$ select now()::text $$;

create or replace function public.sync_has_changes(since_at timestamptz)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.boards where updated_at > since_at
    union all select 1 from public.columns where updated_at > since_at
    union all select 1 from public.songs where updated_at > since_at
    union all select 1 from public.labels where updated_at > since_at
    union all select 1 from public.artists where updated_at > since_at
    union all select 1 from public.attachments where updated_at > since_at
    union all select 1 from public.sync_tombstones where deleted_at > since_at
  );
$$;

revoke all on function public.sync_server_time() from public;
revoke all on function public.sync_has_changes(timestamptz) from public;
grant execute on function public.sync_server_time() to authenticated;
grant execute on function public.sync_has_changes(timestamptz) to authenticated;

-- Existing select policies must hide tombstoned rows while retaining them for sync.
drop policy if exists "boards_select_authenticated" on public.boards;
create policy "boards_select_authenticated" on public.boards for select to authenticated
using (not deleted and (created_by = (select auth.uid()) or (select private.is_admin(created_by))));

drop policy if exists "columns_select_authenticated" on public.columns;
create policy "columns_select_authenticated" on public.columns for select to authenticated
using (
  not deleted and (
    created_by = (select auth.uid()) or exists (
      select 1 from public.boards
      where boards.id = board_id and not boards.deleted
        and (select private.is_admin(boards.created_by))
    )
  )
);

drop policy if exists "labels_select_authenticated" on public.labels;
create policy "labels_select_authenticated" on public.labels for select to authenticated
using (not deleted and (created_by = (select auth.uid()) or (select private.is_admin(created_by))));

drop policy if exists "artists_select_authenticated" on public.artists;
create policy "artists_select_authenticated" on public.artists for select to authenticated
using (not deleted and (created_by = (select auth.uid()) or (select private.is_admin(created_by))));

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'songs'
  ) then
    alter publication supabase_realtime add table public.songs;
  end if;
end $$;
