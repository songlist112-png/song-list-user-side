-- RLS policies do not grant table privileges by themselves.
-- Authenticated users need both privileges and a passing RLS policy.

GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE
    public.boards,
    public.columns,
    public.songs,
    public.labels,
    public.artists,
    public.song_labels,
    public.song_artists
TO authenticated;
