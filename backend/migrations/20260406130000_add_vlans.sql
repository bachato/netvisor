-- Create VLANs entity table
CREATE TABLE IF NOT EXISTS vlans (
    id UUID PRIMARY KEY,
    vlan_number SMALLINT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    source JSONB NOT NULL DEFAULT '"Manual"',
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_vlans_network ON vlans(network_id);
CREATE INDEX IF NOT EXISTS idx_vlans_organization ON vlans(organization_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_vlans_network_number ON vlans(network_id, vlan_number);

-- IfEntry VLAN fields reference VLAN entity UUIDs
ALTER TABLE if_entries ADD COLUMN native_vlan_id UUID REFERENCES vlans(id) ON DELETE SET NULL;
ALTER TABLE if_entries ADD COLUMN vlan_ids JSONB;

-- Subnet-VLAN many-to-many junction table
CREATE TABLE IF NOT EXISTS subnet_vlans (
    id UUID PRIMARY KEY,
    subnet_id UUID NOT NULL REFERENCES subnets(id) ON DELETE CASCADE,
    vlan_id UUID NOT NULL REFERENCES vlans(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    UNIQUE (subnet_id, vlan_id)
);

CREATE INDEX IF NOT EXISTS idx_subnet_vlans_subnet ON subnet_vlans(subnet_id);
CREATE INDEX IF NOT EXISTS idx_subnet_vlans_vlan ON subnet_vlans(vlan_id);
