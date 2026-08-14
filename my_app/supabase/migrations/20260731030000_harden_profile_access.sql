-- Profiles contain private account data and authorization state.
-- Clients may read only their own row and update only display fields.
-- Recovery must use a new audited migration; never restore public profile
-- reads or unrestricted client updates.

alter table public.profiles enable row level security;

drop policy if exists "Public profiles are viewable by everyone."
on public.profiles;
drop policy if exists "Users can insert their own profile."
on public.profiles;
drop policy if exists "Users can update own profile."
on public.profiles;
drop policy if exists profiles_select_self
on public.profiles;
drop policy if exists profiles_update_self
on public.profiles;

revoke all on table public.profiles from public, anon;
revoke insert, update, delete on table public.profiles from authenticated;
revoke insert (id, email, full_name, avatar_url, role, created_at, updated_at)
on public.profiles
from authenticated;
revoke update (id, email, full_name, avatar_url, role, created_at, updated_at)
on public.profiles
from authenticated;
grant select on table public.profiles to authenticated;
grant update (full_name, avatar_url) on table public.profiles to authenticated;

create policy profiles_select_self
on public.profiles
for select
to authenticated
using (id = (select auth.uid()));

create policy profiles_update_self
on public.profiles
for update
to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));
