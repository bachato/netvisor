-- Fix entity_type values in entity_tags junction table
--
-- The original migration (20260106204402_entity_tags_junction.sql) inserted plain
-- strings like 'Host' but the Rust code deserializes with serde_json::from_str()
-- which expects JSON strings like '"Host"'.
--
-- This migration wraps any unquoted entity_type values in JSON string quotes.
-- Values already in correct format (from records created after the migration) are skipped.

UPDATE entity_tags
SET entity_type = '"' || entity_type || '"'
WHERE entity_type NOT LIKE '"%"';
