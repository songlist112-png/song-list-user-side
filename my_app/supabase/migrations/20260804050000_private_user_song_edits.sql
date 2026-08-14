-- Private, offline-first personal lyrics layered over admin-managed songs.

create table public.user_song_edits (
  id uuid primary key,
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  song_id uuid not null references public.songs(id) on delete cascade,
  lyrics text not null default '',
  client_updated_at timestamptz not null,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  constraint user_song_edits_user_song_key unique (user_id, song_id),
  constraint user_song_edits_lyrics_length check (char_length(lyrics) <= 100000)
);

create index user_song_edits_user_updated_idx
on public.user_song_edits(user_id, updated_at);
create index user_song_edits_song_id_idx
on public.user_song_edits(song_id);

create trigger update_user_song_edits_updated_at
before update on public.user_song_edits
for each row execute function public.update_updated_at_column();

alter table public.user_song_edits enable row level security;

create policy "user_song_edits_select_owner"
on public.user_song_edits for select to authenticated
using (user_id = (select auth.uid()));

create policy "user_song_edits_insert_owner_admin_song"
on public.user_song_edits for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.songs
    where songs.id = song_id
      and (select private.is_admin(songs.created_by))
  )
);

create policy "user_song_edits_update_owner_admin_song"
on public.user_song_edits for update to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.songs
    where songs.id = song_id
      and (select private.is_admin(songs.created_by))
  )
);

grant select, insert, update on public.user_song_edits to authenticated;
revoke all on public.user_song_edits from anon;

create or replace function public.sync_upsert_user_song_edit(
  p_id uuid,
  p_song_id uuid,
  p_lyrics text,
  p_client_updated_at timestamptz,
  p_deleted boolean
)
returns public.user_song_edits
language plpgsql
security invoker
set search_path = ''
as $$
declare result public.user_song_edits;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if char_length(p_lyrics) > 100000 then
    raise exception 'Lyrics exceed maximum length' using errcode = '22001';
  end if;

  insert into public.user_song_edits (
    id, user_id, song_id, lyrics, client_updated_at, deleted
  ) values (
    p_id, (select auth.uid()), p_song_id, p_lyrics, p_client_updated_at, p_deleted
  )
  on conflict (user_id, song_id) do update
  set lyrics = excluded.lyrics,
      client_updated_at = excluded.client_updated_at,
      deleted = excluded.deleted
  where excluded.client_updated_at >= public.user_song_edits.client_updated_at
  returning * into result;

  if result.id is null then
    select * into result
    from public.user_song_edits
    where user_id = (select auth.uid()) and song_id = p_song_id;
  end if;
  return result;
end;
$$;

revoke all on function public.sync_upsert_user_song_edit(
  uuid, uuid, text, timestamptz, boolean
) from public;
grant execute on function public.sync_upsert_user_song_edit(
  uuid, uuid, text, timestamptz, boolean
) to authenticated;

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
    union all select 1 from public.user_song_edits
      where user_id = (select auth.uid()) and updated_at > since_at
  );
$$;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'user_song_edits'
  ) then
    alter publication supabase_realtime add table public.user_song_edits;
  end if;
end $$;
