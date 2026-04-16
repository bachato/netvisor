-- Rename groups to dependencies and restructure junction table

-- 1. Rename tables
ALTER TABLE groups RENAME TO dependencies;
ALTER TABLE group_bindings RENAME TO dependency_members;

-- 2. Rename columns
ALTER TABLE dependencies RENAME COLUMN group_type TO dependency_type;
ALTER TABLE dependency_members RENAME COLUMN group_id TO dependency_id;

-- 3. Add service_id column to dependency_members
ALTER TABLE dependency_members ADD COLUMN service_id UUID REFERENCES services(id) ON DELETE CASCADE;

-- 4. Backfill service_id from bindings table
UPDATE dependency_members dm
SET service_id = b.service_id
FROM bindings b
WHERE dm.binding_id = b.id;

-- 5. Remove orphaned rows (binding was deleted but CASCADE didn't fire)
DELETE FROM dependency_members WHERE service_id IS NULL;

-- 6. Make service_id NOT NULL, binding_id nullable
ALTER TABLE dependency_members ALTER COLUMN service_id SET NOT NULL;
ALTER TABLE dependency_members ALTER COLUMN binding_id DROP NOT NULL;

-- 7. Update unique constraint
ALTER TABLE dependency_members DROP CONSTRAINT IF EXISTS group_bindings_group_id_binding_id_key;
ALTER TABLE dependency_members ADD CONSTRAINT dependency_members_dep_service_unique UNIQUE(dependency_id, service_id);

-- 8. Rebuild indexes
DROP INDEX IF EXISTS idx_group_bindings_group;
DROP INDEX IF EXISTS idx_group_bindings_binding;
CREATE INDEX idx_dependency_members_dependency ON dependency_members(dependency_id);
CREATE INDEX idx_dependency_members_service ON dependency_members(service_id);
CREATE INDEX idx_dependency_members_binding ON dependency_members(binding_id) WHERE binding_id IS NOT NULL;

-- 9. Add member_type discriminant to dependencies table
-- Existing groups all had bindings, so default to 'Bindings'
ALTER TABLE dependencies ADD COLUMN member_type TEXT NOT NULL DEFAULT 'Bindings';

-- 10. Rename topology columns
ALTER TABLE topologies RENAME COLUMN groups TO dependencies;
ALTER TABLE topologies RENAME COLUMN removed_groups TO removed_dependencies;

-- 11. Migrate serialized JSONB in topologies.dependencies
--     group_type → dependency_type, binding_ids → members (tagged enum)
UPDATE topologies SET dependencies = (
    SELECT COALESCE(jsonb_agg(
        (dep - 'group_type' - 'binding_ids')
        || jsonb_build_object('dependency_type', dep->>'group_type')
        || jsonb_build_object('members',
            CASE
                WHEN jsonb_array_length(COALESCE(dep->'binding_ids', '[]'::jsonb)) > 0
                THEN jsonb_build_object('type', 'Bindings', 'binding_ids', dep->'binding_ids')
                ELSE jsonb_build_object('type', 'Services', 'service_ids', '[]'::jsonb)
            END
        )
    ), '[]'::jsonb)
    FROM jsonb_array_elements(dependencies) AS dep
)
WHERE dependencies IS NOT NULL AND dependencies != '[]'::jsonb;
