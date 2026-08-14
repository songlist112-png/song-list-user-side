-- ============================================
-- Create songs table
-- ============================================

CREATE TABLE IF NOT EXISTS public.songs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    title TEXT NOT NULL,
    artist TEXT NOT NULL,

    tempo INTEGER,

    key_root TEXT,
    key_type TEXT,

    labels TEXT[] NOT NULL DEFAULT '{}',

    lyrics TEXT NOT NULL DEFAULT '',

    is_published BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================
-- Indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_songs_title
ON public.songs(title);

CREATE INDEX IF NOT EXISTS idx_songs_artist
ON public.songs(artist);

CREATE INDEX IF NOT EXISTS idx_songs_published
ON public.songs(is_published);

CREATE INDEX IF NOT EXISTS idx_songs_deleted
ON public.songs(deleted);

-- ============================================
-- updated_at trigger
-- ============================================

DROP TRIGGER IF EXISTS update_songs_updated_at
ON public.songs;

CREATE TRIGGER update_songs_updated_at
BEFORE UPDATE
ON public.songs
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Enable RLS
-- ============================================

ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Read published songs
-- ============================================

CREATE POLICY "Anyone can view published songs"
ON public.songs
FOR SELECT
USING (
    is_published = TRUE
    AND deleted = FALSE
);

-- ============================================
-- Admin only insert
-- ============================================

CREATE POLICY "Admins can insert songs"
ON public.songs
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
    )
);

-- ============================================
-- Admin only update
-- ============================================

CREATE POLICY "Admins can update songs"
ON public.songs
FOR UPDATE
USING (
    EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
    )
);

-- ============================================
-- Admin only delete
-- ============================================

CREATE POLICY "Admins can delete songs"
ON public.songs
FOR DELETE
USING (
    EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
    )
);
