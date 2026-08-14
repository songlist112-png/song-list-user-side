-- Server-authoritative trial creation and entitlement validation.
UPDATE public.subscriptions
SET expires_at = started_at + INTERVAL '3 hours'
WHERE status = 'trial' AND expires_at IS NULL;

ALTER TABLE public.subscriptions
DROP CONSTRAINT IF EXISTS subscriptions_trial_requires_expiration;

ALTER TABLE public.subscriptions
ADD CONSTRAINT subscriptions_trial_requires_expiration
CHECK (status <> 'trial' OR expires_at IS NOT NULL);

DROP POLICY IF EXISTS "Users can insert their own subscription"
ON public.subscriptions;

DROP POLICY IF EXISTS "Users can update their own subscription"
ON public.subscriptions;

CREATE OR REPLACE FUNCTION public.validate_or_start_subscription()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    subscription_record public.subscriptions%ROWTYPE;
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
    END IF;

    INSERT INTO public.subscriptions (
        user_id,
        plan,
        status,
        started_at,
        expires_at,
        last_validated_at
    )
    VALUES (
        current_user_id,
        'trial',
        'trial',
        NOW(),
        NOW() + INTERVAL '3 hours',
        NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.subscriptions
    SET status = CASE
            WHEN status IN ('trial', 'active')
                 AND expires_at IS NOT NULL
                 AND expires_at <= NOW()
            THEN 'expired'
            ELSE status
        END,
        last_validated_at = NOW()
    WHERE user_id = current_user_id
    RETURNING * INTO subscription_record;

    RETURN jsonb_build_object(
        'plan', subscription_record.plan,
        'status', subscription_record.status,
        'expires_at', subscription_record.expires_at,
        'last_validated_at', subscription_record.last_validated_at
    );
END;
$$;

REVOKE ALL ON FUNCTION public.validate_or_start_subscription() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.validate_or_start_subscription() FROM anon;
GRANT EXECUTE ON FUNCTION public.validate_or_start_subscription()
TO authenticated;
