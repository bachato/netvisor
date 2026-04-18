-- Replace the brittle UNIQUE(host_id, if_index) constraint with a partial
-- UNIQUE(host_id, if_name) WHERE if_name IS NOT NULL.
--
-- Rationale: ifIndex is only stable within a device config lifecycle; it can
-- shift on reboot or config reload on some vendors. ifName ("GigabitEthernet0/1",
-- "eth0") is far more stable when populated. App-layer dedup falls back to
-- if_index / MAC for NULL-if_name rows until they get rescanned and if_name
-- populates.
--
-- Legacy data: v0.15.6 added the if_name column and populated it during SNMP
-- discovery, but had no tier-1 (host_id, if_name) dedup, so upgraders carry
-- duplicate rows that would break the new unique index. We deduplicate first,
-- keeping the most recently updated row per (host_id, if_name) group.
-- Discovery repopulates any interface detail lost with the discarded rows on
-- the next scan (tier-1 match on the surviving row → update). The only FK
-- into this table is the self-reference `neighbor_interface_id` with
-- ON DELETE SET NULL, so cascades are clean.

DELETE FROM interfaces
WHERE if_name IS NOT NULL
  AND id IN (
      SELECT id
      FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                     PARTITION BY host_id, if_name
                     ORDER BY updated_at DESC, id
                 ) AS rn
          FROM interfaces
          WHERE if_name IS NOT NULL
      ) ranked
      WHERE rn > 1
  );

-- Drop original constraint (auto-generated name survived the if_entries → interfaces
-- rename unchanged: migration 20260410000000 renames indexes explicitly but not this
-- constraint, which was declared as `UNIQUE(host_id, if_index)` without a name).
ALTER TABLE interfaces DROP CONSTRAINT if_entries_host_id_if_index_key;

-- New partial unique: enforces identity where we have a strong identifier.
CREATE UNIQUE INDEX idx_interfaces_host_name
    ON interfaces(host_id, if_name)
    WHERE if_name IS NOT NULL;

-- Keep if_index as a non-unique lookup/sort index. InterfaceService::get_for_host
-- orders by if_index ASC, so this path still benefits.
CREATE INDEX idx_interfaces_host_if_index
    ON interfaces(host_id, if_index);
