-- User-level board display preferences shared across devices.
alter table public.user_preferences
add column if not exists view_mode boolean not null default false,
add column if not exists wide_song_columns boolean not null default false;
