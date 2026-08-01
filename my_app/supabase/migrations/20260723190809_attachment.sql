-- ============================================
-- Create attachments table
-- ============================================

CREATE TABLE IF NOT EXISTS public.attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    song_id UUID NOT NULL
        REFERENCES public.songs(id)
        ON DELETE CASCADE,

    file_url TEXT NOT NULL,

    file_type TEXT NOT NULL,

    file_size BIGINT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================
-- Indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_attachments_song_id
ON public.attachments(song_id);

CREATE INDEX IF NOT EXISTS idx_attachments_file_type
ON public.attachments(file_type);

CREATE INDEX IF NOT EXISTS idx_attachments_deleted
ON public.attachments(deleted);

-- ============================================
-- Update updated_at automatically
-- ============================================

DROP TRIGGER IF EXISTS update_attachments_updated_at
ON public.attachments;

CREATE TRIGGER update_attachments_updated_at
BEFORE UPDATE
ON public.attachments
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Enable Row Level Security
-- ============================================

ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Read published song attachments
-- ============================================

CREATE POLICY "Anyone can view published song attachments"
ON public.attachments
FOR SELECT
USING (
    deleted = FALSE
    AND EXISTS (
        SELECT 1
        FROM public.songs s
        WHERE s.id = song_id
          AND s.is_published = TRUE
          AND s.deleted = FALSE
    )
);

-- ============================================
-- Admin insert
-- ============================================

CREATE POLICY "Admins can insert attachments"
ON public.attachments
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = auth.uid()
          AND p.role = 'admin'
    )
);

-- ============================================
-- Admin update
-- ============================================

CREATE POLICY "Admins can update attachments"
ON public.attachments
FOR UPDATE
USING (
    EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = auth.uid()
          AND p.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = auth.uid()
          AND p.role = 'admin'
    )
);

-- ============================================
-- Admin delete
-- ============================================

CREATE POLICY "Admins can delete attachments"
ON public.attachments
FOR DELETE
USING (
    EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.id = auth.uid()
          AND p.role = 'admin'
    )
);
