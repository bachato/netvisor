-- Rename FirstGroupCreated to FirstDependencyCreated in onboarding JSONB arrays
UPDATE organizations
SET onboarding = (onboarding - 'FirstGroupCreated') || '["FirstDependencyCreated"]'::jsonb
WHERE onboarding @> '["FirstGroupCreated"]';
