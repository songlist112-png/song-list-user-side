-- Extend active trials and make all future trials last 14 days.
update public.subscriptions
set expires_at = started_at + interval '14 days'
where plan = 'trial'
  and status = 'trial'
  and expires_at is distinct from started_at + interval '14 days';

create or replace function public.validate_or_start_subscription()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    current_user_id uuid := auth.uid();
    subscription_record public.subscriptions%rowtype;
    trial_duration constant interval := interval '14 days';
begin
    if current_user_id is null then
        raise exception 'Authentication required' using errcode = '42501';
    end if;

    insert into public.subscriptions (
        user_id,
        plan,
        status,
        started_at,
        expires_at,
        last_validated_at
    )
    values (
        current_user_id,
        'trial',
        'trial',
        now(),
        now() + trial_duration,
        now()
    )
    on conflict (user_id) do nothing;

    update public.subscriptions
    set status = case
            when status in ('trial', 'active')
                 and expires_at is not null
                 and expires_at <= now()
            then 'expired'
            else status
        end,
        last_validated_at = now()
    where user_id = current_user_id
    returning * into subscription_record;

    return jsonb_build_object(
        'plan', subscription_record.plan,
        'status', subscription_record.status,
        'expires_at', subscription_record.expires_at,
        'last_validated_at', subscription_record.last_validated_at
    );
end;
$$;

revoke all on function public.validate_or_start_subscription() from public;
revoke all on function public.validate_or_start_subscription() from anon;
grant execute on function public.validate_or_start_subscription()
to authenticated;
