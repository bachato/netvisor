-- SNMP Credentials table
-- Organization-level credential pool with network defaults and per-host overrides

CREATE TABLE snmp_credentials (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    name TEXT NOT NULL,
    version TEXT NOT NULL DEFAULT 'V2c',
    community TEXT NOT NULL,
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_snmp_credentials_org ON snmp_credentials(organization_id);

-- Network default credential
ALTER TABLE networks
    ADD COLUMN snmp_credential_id UUID REFERENCES snmp_credentials(id) ON DELETE SET NULL;

CREATE INDEX idx_networks_snmp_credential ON networks(snmp_credential_id);

COMMENT ON TABLE snmp_credentials IS 'SNMP credentials scoped to organization, reusable across networks';
COMMENT ON COLUMN snmp_credentials.version IS 'SNMP version: V2c (MVP), V3 (future)';
COMMENT ON COLUMN snmp_credentials.community IS 'SNMPv2c community string (encrypted)';
COMMENT ON COLUMN networks.snmp_credential_id IS 'Default SNMP credential for this network (presence enables SNMP discovery)';
