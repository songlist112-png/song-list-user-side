-- Dark mode is a user preference shared by all personal and admin boards.
alter table public.user_preferences
add column if not exists dark_mode boolean not null default false;
