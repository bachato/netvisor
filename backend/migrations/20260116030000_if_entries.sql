-- IfEntry table
-- Represents SNMP ifTable entries - physical ports, logical interfaces, tunnels, LAGs, etc.

CREATE TABLE if_entries (
    id UUID PRIMARY KEY,
    host_id UUID NOT NULL REFERENCES hosts(id) ON DELETE CASCADE,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- SNMP identifiers
    if_index INTEGER NOT NULL,
    if_descr TEXT NOT NULL,
    if_alias TEXT,

    -- Type (raw SNMP integer - interpreted via IANAifType lookup)
    if_type INTEGER NOT NULL,

    -- Speed (bits per second)
    speed_bps BIGINT,

    -- Status (raw SNMP integers per IF-MIB RFC 2863)
    admin_status INTEGER NOT NULL,
    oper_status INTEGER NOT NULL,

    -- Local links
    -- MAC address from SNMP ifPhysAddress (immutable once set)
    mac_address MACADDR,
    -- FK to Interface entity when this ifEntry has an IP address (must be on same host)
    interface_id UUID REFERENCES interfaces(id) ON DELETE SET NULL,

    -- Neighbor resolution (LLDP/CDP) - mutually exclusive
    -- Full resolution: specific remote port identified
    neighbor_if_entry_id UUID REFERENCES if_entries(id) ON DELETE SET NULL,
    -- Partial resolution: remote device identified, port unknown
    neighbor_host_id UUID REFERENCES hosts(id) ON DELETE SET NULL,

    -- Raw LLDP data (from lldpRemTable, used for resolution and display)
    lldp_chassis_id JSONB,              -- LldpChassisId enum as JSON
    lldp_port_id JSONB,                 -- LldpPortId enum as JSON
    lldp_sys_name TEXT,                 -- Remote system name (lldpRemSysName)
    lldp_port_desc TEXT,                -- Remote port description (lldpRemPortDesc)
    lldp_mgmt_addr INET,                -- Remote management IP (lldpRemManAddrTable)
    lldp_sys_desc TEXT,                 -- Remote system description (lldpRemSysDesc)

    -- Raw CDP data (from cdpCacheTable, Cisco Discovery Protocol)
    cdp_device_id TEXT,                 -- Remote device hostname (cdpCacheDeviceId)
    cdp_port_id TEXT,                   -- Remote port string (cdpCacheDevicePort)
    cdp_platform TEXT,                  -- Remote platform (cdpCachePlatform)
    cdp_address INET,                   -- Remote management IP (cdpCacheAddress)

    -- Constraints
    UNIQUE(host_id, if_index),
    -- Neighbor fields are mutually exclusive: at most one can be set
    CONSTRAINT chk_neighbor_exclusive CHECK (
        (neighbor_if_entry_id IS NULL) OR (neighbor_host_id IS NULL)
    )
);

CREATE INDEX idx_if_entries_host ON if_entries(host_id);
CREATE INDEX idx_if_entries_network ON if_entries(network_id);
CREATE INDEX idx_if_entries_interface ON if_entries(interface_id);
CREATE INDEX idx_if_entries_mac_address ON if_entries(mac_address);
CREATE INDEX idx_if_entries_neighbor_if_entry ON if_entries(neighbor_if_entry_id);
CREATE INDEX idx_if_entries_neighbor_host ON if_entries(neighbor_host_id);

COMMENT ON TABLE if_entries IS 'SNMP ifTable entries - physical/logical interfaces on network devices';
COMMENT ON COLUMN if_entries.if_index IS 'SNMP ifIndex - stable identifier within device';
COMMENT ON COLUMN if_entries.if_descr IS 'SNMP ifDescr - interface description (e.g., GigabitEthernet0/1)';
COMMENT ON COLUMN if_entries.if_alias IS 'SNMP ifAlias - user-configured description';
COMMENT ON COLUMN if_entries.if_type IS 'SNMP ifType - IANAifType integer (6=ethernet, 24=loopback, etc.)';
COMMENT ON COLUMN if_entries.speed_bps IS 'Interface speed from ifSpeed/ifHighSpeed in bits per second';
COMMENT ON COLUMN if_entries.admin_status IS 'SNMP ifAdminStatus: 1=up, 2=down, 3=testing';
COMMENT ON COLUMN if_entries.oper_status IS 'SNMP ifOperStatus: 1=up, 2=down, 3=testing, 4=unknown, 5=dormant, 6=notPresent, 7=lowerLayerDown';
COMMENT ON COLUMN if_entries.interface_id IS 'FK to Interface entity when this ifEntry has an IP address (must be on same host)';
COMMENT ON COLUMN if_entries.neighbor_if_entry_id IS 'Full neighbor resolution: FK to remote IfEntry discovered via LLDP/CDP';
COMMENT ON COLUMN if_entries.neighbor_host_id IS 'Partial neighbor resolution: FK to remote Host when specific port is unknown';
COMMENT ON COLUMN if_entries.lldp_mgmt_addr IS 'LLDP remote management address (lldpRemManAddr)';
COMMENT ON COLUMN if_entries.lldp_sys_desc IS 'LLDP remote system description (lldpRemSysDesc)';
COMMENT ON COLUMN if_entries.cdp_device_id IS 'CDP cache remote device ID (typically hostname)';
COMMENT ON COLUMN if_entries.cdp_port_id IS 'CDP cache remote port ID string';
COMMENT ON COLUMN if_entries.cdp_platform IS 'CDP cache remote device platform (e.g., Cisco IOS)';
COMMENT ON COLUMN if_entries.cdp_address IS 'CDP cache remote device management IP address';

-- Add if_entries to topology snapshots (for building PhysicalLink edges)
ALTER TABLE topologies ADD COLUMN if_entries JSONB NOT NULL DEFAULT '[]';
ALTER TABLE topologies ADD COLUMN removed_if_entries UUID[] DEFAULT '{}';
