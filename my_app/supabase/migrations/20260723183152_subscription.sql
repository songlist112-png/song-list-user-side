-- ============================================
-- Create update_updated_at_column() function
-- ============================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- ============================================
-- Create subscriptions table
-- ============================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    plan TEXT NOT NULL,

    status TEXT NOT NULL
        CHECK (
            status IN (
                'trial',
                'active',
                'expired',
                'canceled'
            )
        ),

    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,

    stripe_customer_id TEXT,

    last_validated_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT subscriptions_user_id_key UNIQUE (user_id)
);

-- ============================================
-- Indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id
ON public.subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_status
ON public.subscriptions(status);

CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_at
ON public.subscriptions(expires_at);

-- ============================================
-- Trigger
-- ============================================

DROP TRIGGER IF EXISTS update_subscriptions_updated_at
ON public.subscriptions;

CREATE TRIGGER update_subscriptions_updated_at
BEFORE UPDATE
ON public.subscriptions
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Enable Row Level Security
-- ============================================

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Policies
-- ============================================

DROP POLICY IF EXISTS "Users can view their own subscription"
ON public.subscriptions;

CREATE POLICY "Users can view their own subscription"
ON public.subscriptions
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own subscription"
ON public.subscriptions;

CREATE POLICY "Users can insert their own subscription"
ON public.subscriptions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own subscription"
ON public.subscriptions;

CREATE POLICY "Users can update their own subscription"
ON public.subscriptions
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
