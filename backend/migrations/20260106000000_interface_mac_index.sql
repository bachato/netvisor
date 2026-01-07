-- Add index for MAC address lookups during interface deduplication
-- This enables efficient fallback matching when subnet_id differs between discovery runs
-- Partial index excludes NULL mac_address values for efficiency
CREATE INDEX IF NOT EXISTS idx_interfaces_host_mac
ON interfaces(host_id, mac_address)
WHERE mac_address IS NOT NULL;
