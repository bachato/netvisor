-- Add HubSpot company ID to organizations table
-- Stores the HubSpot company ID after initial sync to avoid duplicate company creation
-- and enable direct updates without search-based lookups

ALTER TABLE organizations ADD COLUMN hubspot_company_id TEXT;
