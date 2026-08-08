-- User preferences mirrored to the server so settings survive re-installs.
-- One row per user, keyed by the profiles primary key.

create table if not exists public.user_preferences (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  lyrics_font_scale double precision not null default 1.0,
  updated_at timestamptz not null default now()
);

alter table public.user_preferences enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update
on table public.user_preferences to authenticated;

drop policy if exists "user_preferences_owner_manage" on public.user_preferences;
create policy "user_preferences_owner_manage"
on public.user_preferences for all to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
