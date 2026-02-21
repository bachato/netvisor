-- Add plan_limit_notifications column for tracking which plan limit emails have been sent
ALTER TABLE organizations ADD COLUMN plan_limit_notifications JSONB NOT NULL DEFAULT '{}';
