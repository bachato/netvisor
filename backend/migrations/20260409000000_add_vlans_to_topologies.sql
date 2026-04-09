-- Add VLANs to topology snapshot for frontend VLAN name resolution
ALTER TABLE topologies ADD COLUMN vlans JSONB NOT NULL DEFAULT '[]';
