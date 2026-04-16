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

-- Drop both CHECK constraints first (they reference old column name and old discriminant)
ALTER TABLE bindings DROP CONSTRAINT IF EXISTS bindings_binding_type_check;
ALTER TABLE bindings DROP CONSTRAINT IF EXISTS valid_binding;

-- Now safe to rename and update
ALTER TABLE bindings RENAME COLUMN interface_id TO ip_address_id;
UPDATE bindings SET binding_type = 'IPAddress' WHERE binding_type = 'Interface';

-- Recreate CHECK constraints with new names
ALTER TABLE bindings ADD CONSTRAINT bindings_binding_type_check
    CHECK (binding_type IN ('IPAddress', 'Port'));
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
-- 5. Migrate serialized JSONB in topologies.interfaces (formerly if_entries)
--    interface_id → ip_address_id, neighbor.type "IfEntry" → "Interface"
-- ============================================================
UPDATE topologies SET interfaces = (
    SELECT COALESCE(jsonb_agg(
        (iface::jsonb - 'interface_id')
        || jsonb_build_object('ip_address_id', iface->'interface_id')
        || CASE
            WHEN iface->'neighbor' IS NOT NULL AND iface->'neighbor' != 'null'::jsonb
                 AND iface->'neighbor'->>'type' = 'IfEntry'
            THEN jsonb_build_object('neighbor',
                (iface->'neighbor')::jsonb - 'type' || jsonb_build_object('type', 'Interface')
            )
            ELSE '{}'::jsonb
        END
    ), '[]'::jsonb)
    FROM jsonb_array_elements(interfaces) AS iface
)
WHERE interfaces IS NOT NULL AND interfaces != '[]'::jsonb;

-- ============================================================
-- 5b. Migrate serialized JSONB in topologies.nodes
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
-- 5c. Migrate serialized JSONB in topologies.edges
--    Variant renames: Interface→SameHost, HostVirtualization→Hypervisor,
--                     ServiceVirtualization→ContainerRuntime
--    Field renames:   vm_service_id→hypervisor_service_id,
--                     containerizing_service_id→service_id,
--                     group_id→dependency_id, source_binding_id→source_id,
--                     target_binding_id→target_id,
--                     source_if_entry_id→source_entity_id,
--                     target_if_entry_id→target_entity_id
-- ============================================================
UPDATE topologies SET edges = (
    SELECT COALESCE(jsonb_agg(
        CASE
            WHEN edge->>'edge_type' = 'Interface' THEN
                (edge - 'edge_type')
                || jsonb_build_object('edge_type', 'SameHost')
            WHEN edge->>'edge_type' = 'HostVirtualization' THEN
                (edge - 'edge_type' - 'vm_service_id')
                || jsonb_build_object(
                    'edge_type', 'Hypervisor',
                    'hypervisor_service_id', edge->'vm_service_id'
                )
            WHEN edge->>'edge_type' = 'ServiceVirtualization' THEN
                (edge - 'edge_type' - 'containerizing_service_id')
                || jsonb_build_object(
                    'edge_type', 'ContainerRuntime',
                    'service_id', edge->'containerizing_service_id'
                )
            WHEN edge->>'edge_type' = 'RequestPath' THEN
                (edge - 'group_id' - 'source_binding_id' - 'target_binding_id')
                || jsonb_build_object(
                    'dependency_id', edge->'group_id',
                    'source_id', edge->'source_binding_id',
                    'target_id', edge->'target_binding_id'
                )
            WHEN edge->>'edge_type' = 'HubAndSpoke' THEN
                (edge - 'group_id' - 'source_binding_id' - 'target_binding_id')
                || jsonb_build_object(
                    'dependency_id', edge->'group_id',
                    'source_id', edge->'source_binding_id',
                    'target_id', edge->'target_binding_id'
                )
            WHEN edge->>'edge_type' = 'PhysicalLink' THEN
                (edge - 'source_if_entry_id' - 'target_if_entry_id')
                || jsonb_build_object(
                    'source_entity_id', edge->'source_if_entry_id',
                    'target_entity_id', edge->'target_if_entry_id'
                )
            ELSE edge
        END
    ), '[]'::jsonb)
    FROM jsonb_array_elements(edges) AS edge
)
WHERE edges IS NOT NULL AND edges != '[]'::jsonb;

-- ============================================================
-- 5d. Migrate hide_edge_types in topology local options
--    Interface→SameHost, HostVirtualization→Hypervisor,
--    ServiceVirtualization→ContainerRuntime
-- ============================================================
UPDATE topologies SET options = jsonb_set(
    options,
    '{local,hide_edge_types}',
    (
        SELECT COALESCE(jsonb_agg(
            CASE val
                WHEN 'Interface' THEN '"SameHost"'::jsonb
                WHEN 'HostVirtualization' THEN '"Hypervisor"'::jsonb
                WHEN 'ServiceVirtualization' THEN '"ContainerRuntime"'::jsonb
                ELSE to_jsonb(val)
            END
        ), '[]'::jsonb)
        FROM jsonb_array_elements_text(options->'local'->'hide_edge_types') AS val
    )
)
WHERE options->'local'->'hide_edge_types' IS NOT NULL;

-- ============================================================
-- 6. Rename host_credentials column
-- ============================================================
ALTER TABLE host_credentials RENAME COLUMN interface_ids TO ip_address_ids;

-- ============================================================
-- 7. Table comments
-- ============================================================
COMMENT ON TABLE ip_addresses IS 'IP addresses assigned to hosts on subnets';
COMMENT ON TABLE interfaces IS 'SNMP ifTable entries - physical/logical interfaces on network devices';
