-- Host SNMP fields
-- System MIB data, management URL, chassis ID for deduplication, and credential override

ALTER TABLE hosts
    ADD COLUMN sys_descr TEXT,
    ADD COLUMN sys_object_id TEXT,
    ADD COLUMN sys_location TEXT,
    ADD COLUMN sys_contact TEXT,
    ADD COLUMN management_url TEXT,
    ADD COLUMN chassis_id TEXT,
    ADD COLUMN snmp_credential_id UUID REFERENCES snmp_credentials(id) ON DELETE SET NULL;

CREATE INDEX idx_hosts_snmp_credential ON hosts(snmp_credential_id);
CREATE INDEX idx_hosts_chassis_id ON hosts(chassis_id);

COMMENT ON COLUMN hosts.sys_descr IS 'SNMP sysDescr.0 - full system description';
COMMENT ON COLUMN hosts.sys_object_id IS 'SNMP sysObjectID.0 - vendor OID for device identification';
COMMENT ON COLUMN hosts.sys_location IS 'SNMP sysLocation.0 - physical location';
COMMENT ON COLUMN hosts.sys_contact IS 'SNMP sysContact.0 - admin contact info';
COMMENT ON COLUMN hosts.management_url IS 'URL for device management interface (manual or discovered)';
COMMENT ON COLUMN hosts.chassis_id IS 'LLDP lldpLocChassisId - globally unique device identifier for deduplication';
COMMENT ON COLUMN hosts.snmp_credential_id IS 'Per-host SNMP credential override (null = use network default)';
