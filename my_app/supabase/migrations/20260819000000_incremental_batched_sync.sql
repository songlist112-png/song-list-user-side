-- Versioned, cursor-based pull APIs for the mobile offline cache.
-- Attachment rows contain metadata only; storage objects remain lazy-loaded.

create index if not exists boards_sync_cursor_idx
on public.boards(updated_at, id);
create index if not exists columns_sync_cursor_idx
on public.columns(updated_at, id);
create index if not exists songs_sync_cursor_idx
on public.songs(updated_at, id);
create index if not exists labels_sync_cursor_idx
on public.labels(updated_at, id);
create index if not exists artists_sync_cursor_idx
on public.artists(updated_at, id);

do $$
declare
  table_name text;
begin
  foreach table_name in array array['boards', 'columns', 'labels', 'artists', 'attachments'] loop
    if not exists (
      select 1
      from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = table_name
    ) then
      execute format('alter publication supabase_realtime add table public.%I', table_name);
    end if;
  end loop;
end $$;

alter table public.sync_tombstones
add column if not exists owner_id uuid;

create index if not exists sync_tombstones_owner_cursor_idx
on public.sync_tombstones(owner_id, deleted_at, id);

create or replace function public.capture_sync_tombstone()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_data jsonb := to_jsonb(old);
  v_owner_id uuid;
begin
  v_owner_id := nullif(v_data ->> 'created_by', '')::uuid;
  if v_owner_id is null and tg_table_name = 'attachments' then
    select songs.created_by
    into v_owner_id
    from public.songs
    where songs.id = nullif(v_data ->> 'song_id', '')::uuid;
  end if;

  insert into public.sync_tombstones(entity_type, entity_id, owner_id)
  values (tg_table_name, old.id, v_owner_id);
  return old;
end;
$$;

create or replace function public.touch_sync_song()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_song_id uuid;
begin
  if tg_op = 'DELETE' then
    v_song_id := old.song_id;
  else
    v_song_id := new.song_id;
  end if;

  update public.songs
  set updated_at = now()
  where id = v_song_id;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array['song_labels', 'song_artists', 'attachments'] loop
    execute format('drop trigger if exists touch_song_for_sync on public.%I', table_name);
    execute format(
      'create trigger touch_song_for_sync after insert or update or delete on public.%I '
      'for each row execute function public.touch_sync_song()',
      table_name
    );
  end loop;
end $$;

create or replace function public.touch_artist_songs_for_sync()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.songs
  set updated_at = now()
  where id in (
    select song_artists.song_id
    from public.song_artists
    where song_artists.artist_id = new.id
  );
  return new;
end;
$$;

drop trigger if exists touch_artist_songs_for_sync on public.artists;
create trigger touch_artist_songs_for_sync
after update on public.artists
for each row execute function public.touch_artist_songs_for_sync();

create or replace function public.sync_pull_structure(
  p_since timestamptz default null,
  p_until timestamptz default now()
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, private
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'current_user_is_admin', private.is_admin(v_user_id),
    'boards', coalesce((
      select jsonb_agg(to_jsonb(boards) order by boards.updated_at, boards.id)
      from public.boards
      where boards.updated_at <= p_until
        and (boards.created_by = v_user_id or private.is_admin(boards.created_by))
        and (
          (p_since is null and not boards.deleted)
          or (p_since is not null and boards.updated_at > p_since)
        )
    ), '[]'::jsonb),
    'columns', coalesce((
      select jsonb_agg(to_jsonb(columns) order by columns.updated_at, columns.id)
      from public.columns
      where columns.updated_at <= p_until
        and (
          columns.created_by = v_user_id
          or exists (
            select 1 from public.boards
            where boards.id = columns.board_id
              and private.is_admin(boards.created_by)
          )
        )
        and (
          (p_since is null and not columns.deleted)
          or (p_since is not null and columns.updated_at > p_since)
        )
    ), '[]'::jsonb),
    'labels', coalesce((
      select jsonb_agg(to_jsonb(labels) order by labels.updated_at, labels.id)
      from public.labels
      where labels.updated_at <= p_until
        and (labels.created_by = v_user_id or private.is_admin(labels.created_by))
        and (
          (p_since is null and not labels.deleted)
          or (p_since is not null and labels.updated_at > p_since)
        )
    ), '[]'::jsonb),
    'artists', coalesce((
      select jsonb_agg(to_jsonb(artists) order by artists.updated_at, artists.id)
      from public.artists
      where artists.updated_at <= p_until
        and (artists.created_by = v_user_id or private.is_admin(artists.created_by))
        and (
          (p_since is null and not artists.deleted)
          or (p_since is not null and artists.updated_at > p_since)
        )
    ), '[]'::jsonb),
    'tombstones', case when p_since is null then '[]'::jsonb else coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'entity_type', sync_tombstones.entity_type,
          'entity_id', sync_tombstones.entity_id,
          'deleted_at', sync_tombstones.deleted_at
        ) order by sync_tombstones.deleted_at, sync_tombstones.id
      )
      from public.sync_tombstones
      where sync_tombstones.deleted_at > p_since
        and sync_tombstones.deleted_at <= p_until
        and (
          sync_tombstones.owner_id = v_user_id
          or private.is_admin(sync_tombstones.owner_id)
        )
    ), '[]'::jsonb) end
  );
end;
$$;

create or replace function public.sync_pull_song_page(
  p_since timestamptz default null,
  p_until timestamptz default now(),
  p_cursor_updated_at timestamptz default null,
  p_cursor_id uuid default null,
  p_page_size integer default 500
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, private
as $$
declare
  v_user_id uuid := auth.uid();
  v_page_size integer := least(greatest(coalesce(p_page_size, 500), 1), 1000);
  v_rows jsonb;
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if (p_cursor_updated_at is null) <> (p_cursor_id is null) then
    raise exception 'Both cursor values are required' using errcode = '22023';
  end if;

  with page as (
    select songs.*
    from public.songs
    where songs.updated_at <= p_until
      and (songs.created_by = v_user_id or private.is_admin(songs.created_by))
      and (
        (p_since is null and not songs.deleted)
        or (p_since is not null and songs.updated_at > p_since)
      )
      and (
        p_cursor_updated_at is null
        or (songs.updated_at, songs.id) > (p_cursor_updated_at, p_cursor_id)
      )
    order by songs.updated_at, songs.id
    limit v_page_size
  )
  select coalesce(jsonb_agg(
    to_jsonb(page) || jsonb_build_object(
      'artist_name', (
        select artists.name
        from public.song_artists
        join public.artists on artists.id = song_artists.artist_id
        where song_artists.song_id = page.id
          and not artists.deleted
        order by (song_artists.role = 'primary') desc, artists.id
        limit 1
      ),
      'label_ids', coalesce((
        select jsonb_agg(song_labels.label_id order by song_labels.label_id)
        from public.song_labels
        join public.labels on labels.id = song_labels.label_id
        where song_labels.song_id = page.id
          and not labels.deleted
      ), '[]'::jsonb),
      'attachments', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', attachments.id,
            'file_url', attachments.file_url,
            'file_type', attachments.file_type,
            'file_size', attachments.file_size
          ) order by attachments.id
        )
        from public.attachments
        where attachments.song_id = page.id
          and not attachments.deleted
      ), '[]'::jsonb)
    ) order by page.updated_at, page.id
  ), '[]'::jsonb)
  into v_rows
  from page;

  return v_rows;
end;
$$;

revoke all on function public.sync_pull_structure(timestamptz, timestamptz)
from public;
grant execute on function public.sync_pull_structure(timestamptz, timestamptz)
to authenticated;

revoke all on function public.sync_pull_song_page(
  timestamptz, timestamptz, timestamptz, uuid, integer
) from public;
grant execute on function public.sync_pull_song_page(
  timestamptz, timestamptz, timestamptz, uuid, integer
) to authenticated;

revoke all on function public.touch_sync_song() from public;
revoke all on function public.touch_artist_songs_for_sync() from public;
