-- Seed development database with a test user, organization, and network
-- This allows skipping the onboarding flow during local development
--
-- Login credentials:
--   Email: dev@localhost
--   Password: password123
--
-- Run with: make seed-dev

-- Use fixed UUIDs for predictability
DO $$
DECLARE
    org_id UUID := 'a0000000-0000-0000-0000-000000000001';
    network_id UUID := 'b0000000-0000-0000-0000-000000000001';
    user_id UUID := 'c0000000-0000-0000-0000-000000000001';
    -- Argon2id hash for "password123"
    password_hash TEXT := '$argon2id$v=19$m=19456,t=2,p=1$I9uvkaWh0CSvKXrdWtTbXQ$0Vi+GhVZYCp7NEnxjTQN58RA9WF5/NIuWgBhbCn7rA4';
    now_ts TIMESTAMPTZ := NOW();
BEGIN
    -- Skip if user already exists (idempotent)
    IF EXISTS (SELECT 1 FROM users WHERE email = 'dev@localhost.com') THEN
        RAISE NOTICE 'Dev user already exists, skipping seed';
        RETURN;
    END IF;

    -- Create organization
    INSERT INTO organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding)
    VALUES (
        org_id,
        'Dev Organization',
        NULL,
        '{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}'::jsonb,
        'active',
        now_ts,
        now_ts,
        '["OrgCreated", "OnboardingModalCompleted"]'::jsonb
    );

    -- Create network
    INSERT INTO networks (id, name, created_at, updated_at, organization_id)
    VALUES (
        network_id,
        'Dev Network',
        now_ts,
        now_ts,
        org_id
    );

    -- Create user (Owner of organization, email verified, password = "password")
    INSERT INTO users (
        id, created_at, updated_at, password_hash,
        oidc_provider, oidc_subject, oidc_linked_at,
        email, organization_id, permissions, tags,
        terms_accepted_at, email_verified,
        email_verification_token, email_verification_expires,
        password_reset_token, password_reset_expires
    )
    VALUES (
        user_id,
        now_ts,
        now_ts,
        password_hash,
        NULL,  -- oidc_provider
        NULL,  -- oidc_subject
        NULL,  -- oidc_linked_at
        'dev@localhost.com',
        org_id,
        'Owner',
        '{}',  -- tags
        now_ts,  -- terms_accepted_at
        TRUE,  -- email_verified
        NULL,  -- email_verification_token
        NULL,  -- email_verification_expires
        NULL,  -- password_reset_token
        NULL   -- password_reset_expires
    );

    -- Grant user access to the network
    INSERT INTO user_network_access (user_id, network_id, created_at)
    VALUES (user_id, network_id, now_ts);

    RAISE NOTICE 'Dev seed complete! Login with: dev@localhost / password123';
END $$;
