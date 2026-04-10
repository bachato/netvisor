-- Rename entities: Interface → IPAddress, IfEntry → Interface
-- All ALTER TABLE RENAME operations are metadata-only (instant in Postgres).

-- ============================================================
-- 1. Rename 'interfaces' table → 'ip_addresses' (frees the name)
-- ============================================================
ALTER TABLE interfaces RENAME TO ip_addresses;
ALTER INDEX idx_interfaces_network RENAME TO idx_ip_addresses_network;
ALTER INDEX idx_interfaces_host RENAME TO idx_ip_addresses_host;
ALTER INDEX idx_interfaces_subnet RENAME TO idx_ip_addresses_subnet;
ALTER INDEX idx_interfaces_host_mac RENAME TO idx_ip_addresses_host_mac;

-- ============================================================
-- 2. Rename 'if_entries' table → 'interfaces'
-- ============================================================
ALTER TABLE if_entries RENAME TO interfaces;

-- Rename columns that reference the old entity names
ALTER TABLE interfaces RENAME COLUMN interface_id TO ip_address_id;
ALTER TABLE interfaces RENAME COLUMN neighbor_if_entry_id TO neighbor_interface_id;

-- Rename indexes
ALTER INDEX idx_if_entries_host RENAME TO idx_interfaces_host;
ALTER INDEX idx_if_entries_network RENAME TO idx_interfaces_network;
ALTER INDEX idx_if_entries_interface RENAME TO idx_interfaces_ip_address;
ALTER INDEX idx_if_entries_mac_address RENAME TO idx_interfaces_mac_address;
ALTER INDEX idx_if_entries_neighbor_if_entry RENAME TO idx_interfaces_neighbor_interface;
ALTER INDEX idx_if_entries_neighbor_host RENAME TO idx_interfaces_neighbor_host;

-- ============================================================
-- 3. Update bindings table
-- ============================================================
ALTER TABLE bindings RENAME COLUMN interface_id TO ip_address_id;

-- Update binding_type discriminant text
UPDATE bindings SET binding_type = 'IPAddress' WHERE binding_type = 'Interface';

-- Recreate CHECK constraints with new discriminant value
ALTER TABLE bindings DROP CONSTRAINT IF EXISTS bindings_binding_type_check;
ALTER TABLE bindings ADD CONSTRAINT bindings_binding_type_check
    CHECK (binding_type IN ('IPAddress', 'Port'));

ALTER TABLE bindings DROP CONSTRAINT IF EXISTS valid_binding;
ALTER TABLE bindings ADD CONSTRAINT valid_binding CHECK (
    (binding_type = 'IPAddress' AND ip_address_id IS NOT NULL AND port_id IS NULL) OR
    (binding_type = 'Port' AND port_id IS NOT NULL)
);

-- Rename binding indexes
ALTER INDEX idx_bindings_interface RENAME TO idx_bindings_ip_address;

-- ============================================================
-- 4. Rename topology snapshot columns (order matters to avoid collision)
-- ============================================================
ALTER TABLE topologies RENAME COLUMN interfaces TO ip_addresses;
ALTER TABLE topologies RENAME COLUMN removed_interfaces TO removed_ip_addresses;
ALTER TABLE topologies RENAME COLUMN if_entries TO interfaces;
ALTER TABLE topologies RENAME COLUMN removed_if_entries TO removed_interfaces;

-- ============================================================
-- 5. Migrate serialized JSONB in topologies.nodes
--    element_type "Interface" → "IPAddress" (+ interface_id → ip_address_id)
--    element_type "Port" → "Interface" (+ if_entry_id → interface_id)
-- ============================================================
UPDATE topologies SET nodes = (
    SELECT COALESCE(jsonb_agg(
        CASE
            WHEN node->>'element_type' = 'Interface' THEN
                (node - 'element_type' - 'interface_id')
                || jsonb_build_object('element_type', 'IPAddress')
                || CASE
                    WHEN node ? 'interface_id' THEN jsonb_build_object('ip_address_id', node->'interface_id')
                    ELSE '{}'::jsonb
                END
            WHEN node->>'element_type' = 'Port' THEN
                (node - 'element_type' - 'if_entry_id')
                || jsonb_build_object(
                    'element_type', 'Interface',
                    'interface_id', node->'if_entry_id'
                )
            ELSE node
        END
    ), '[]'::jsonb)
    FROM jsonb_array_elements(nodes) AS node
)
WHERE nodes IS NOT NULL AND nodes != '[]'::jsonb;

-- ============================================================
-- 6. Table comments
-- ============================================================
COMMENT ON TABLE ip_addresses IS 'IP addresses assigned to hosts on subnets';
COMMENT ON TABLE interfaces IS 'SNMP ifTable entries - physical/logical interfaces on network devices';
