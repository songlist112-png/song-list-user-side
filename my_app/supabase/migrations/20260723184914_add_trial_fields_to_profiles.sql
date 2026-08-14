-- ============================================
-- Add trial usage fields to profiles
-- ============================================

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS trial_minutes_used INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;
