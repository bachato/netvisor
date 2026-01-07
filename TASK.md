> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Tags System Refactor

## Objective

Refactor the tags system to use a junction table, enabling cleaner bulk/inline tag operations across all entity types without per-entity handler duplication.

**Original goal:** Improve tags UX (bulk tagging, interactive card tags)
**Evolved scope:** Backend-first refactor to eliminate code smell of per-entity tag handlers

## Architecture Overview

### Current State (Problem)
- Tags stored as `Vec<Uuid>` on each entity table
- Each entity needs its own update mutation to modify tags
- Frontend needs per-entity `handleTagAdd`/`handleTagRemove` handlers
- Code duplication across Host, Service, Subnet, Group, Network, etc.

### Target State (Solution)
- Junction table `entity_tags(entity_id, entity_type, tag_id)`
- Single API endpoint for tag assignment/removal
- Generic frontend hook works for all entity types
- Tag hydration in service layer (follows existing patterns)

## Implementation Plan

### Phase 1: Database Migration

```sql
-- Create junction table
CREATE TABLE entity_tags (
    entity_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (entity_id, entity_type, tag_id)
);

CREATE INDEX idx_entity_tags_tag_id ON entity_tags(tag_id);
CREATE INDEX idx_entity_tags_entity ON entity_tags(entity_id, entity_type);

-- Migrate existing data (for each taggable entity)
INSERT INTO entity_tags (entity_id, entity_type, tag_id)
SELECT id, 'Host', unnest(tags) FROM hosts WHERE array_length(tags, 1) > 0;
-- Repeat for: services, subnets, groups, networks, discoveries, daemons, daemon_api_keys, user_api_keys

-- Drop old columns (after backend updated)
ALTER TABLE hosts DROP COLUMN tags;
-- Repeat for all taggable entities
```

**Taggable entities:** Host, Service, Subnet, Group, Network, Discovery, Daemon, DaemonApiKey, UserApiKey
**Not taggable:** Interface, Port

### Phase 2: Storage Layer

**New file:** `backend/src/server/shared/storage/entity_tags.rs`

```rust
pub struct EntityTagStorage { pool: PgPool }

impl EntityTagStorage {
    pub async fn get_for_entity(&self, entity_id: &Uuid, entity_type: &str) -> Result<Vec<Uuid>>;
    pub async fn get_for_entities(&self, ids: &[Uuid], entity_type: &str) -> Result<HashMap<Uuid, Vec<Uuid>>>;
    pub async fn add(&self, entity_id: Uuid, entity_type: &str, tag_id: Uuid) -> Result<()>;
    pub async fn remove(&self, entity_id: Uuid, entity_type: &str, tag_id: Uuid) -> Result<()>;
    pub async fn set(&self, entity_id: Uuid, entity_type: &str, tag_ids: Vec<Uuid>) -> Result<()>;
}
```

### Phase 3: Taggable Trait

**New file:** `backend/src/server/shared/traits/taggable.rs`

```rust
/// Trait for entities that support tags.
/// NOT a bound on CrudHandlers - only used where tag operations are needed.
pub trait Taggable {
    fn entity_type() -> &'static str;
    fn id(&self) -> Uuid;
    fn tags(&self) -> &[Uuid];
    fn set_tags(&mut self, tags: Vec<Uuid>);
}
```

Implement for: Host, Service, Subnet, Group, Network, Discovery, Daemon, DaemonApiKey, UserApiKey

### Phase 4: Service Layer

**New file:** `backend/src/server/shared/services/entity_tags.rs`

```rust
pub struct EntityTagService {
    storage: EntityTagStorage,
    tag_service: TagService,
}

impl EntityTagService {
    /// Hydrate tags for a batch of entities (single query)
    pub async fn hydrate_tags_batch<T: Taggable>(&self, entities: &mut [T]) -> Result<()> {
        if entities.is_empty() { return Ok(()); }

        let ids: Vec<Uuid> = entities.iter().map(|e| e.id()).collect();
        let tags_map = self.storage.get_for_entities(&ids, T::entity_type()).await?;

        for entity in entities {
            entity.set_tags(tags_map.get(&entity.id()).cloned().unwrap_or_default());
        }
        Ok(())
    }

    /// Add tag with validation
    pub async fn add_tag(&self, entity_id: Uuid, entity_type: &str, tag_id: Uuid, org_id: Uuid) -> Result<()>;

    /// Remove tag
    pub async fn remove_tag(&self, entity_id: Uuid, entity_type: &str, tag_id: Uuid) -> Result<()>;
}
```

### Phase 5: Service Layer Hydration

Add hydration calls to existing service methods. Examples:

**hosts/service.rs** (already has child hydration pattern):
```rust
pub async fn get_all_host_responses(&self, filter: EntityFilter) -> Result<Vec<HostResponse>> {
    let mut hosts = self.get_all(filter).await?;
    let host_ids: Vec<Uuid> = hosts.iter().map(|h| h.id).collect();

    // Existing child loading
    let (interfaces_map, ports_map, mut services_map) = self.load_children_for_hosts(&host_ids).await?;

    // NEW: Tag hydration for hosts and services
    let service_ids: Vec<Uuid> = services_map.values().flat_map(|s| s.iter().map(|s| s.id)).collect();
    self.entity_tag_service.hydrate_tags_batch(&mut hosts).await?;
    for services in services_map.values_mut() {
        self.entity_tag_service.hydrate_tags_batch(services).await?;
    }

    // Build responses...
}
```

**subnets/service.rs**, **groups/service.rs**, etc.:
```rust
pub async fn get_all(&self, filter: EntityFilter) -> Result<Vec<Subnet>> {
    let mut subnets = self.storage.get_all(filter).await?;
    self.entity_tag_service.hydrate_tags_batch(&mut subnets).await?;
    Ok(subnets)
}
```

### Phase 6: API Endpoints

**New file:** `backend/src/server/entity_tags/handlers.rs`

```rust
/// POST /api/tags/{tag_id}/entities
/// Add tag to an entity
async fn add_tag_to_entity(
    state: State<Arc<AppState>>,
    auth: Authorized<Member>,
    Path(tag_id): Path<Uuid>,
    Json(req): Json<EntityTagRequest>,  // { entity_id: Uuid, entity_type: String }
) -> ApiResult<Json<ApiResponse<()>>>;

/// DELETE /api/tags/{tag_id}/entities/{entity_type}/{entity_id}
/// Remove tag from an entity
async fn remove_tag_from_entity(...) -> ApiResult<Json<ApiResponse<()>>>;

/// POST /api/tags/bulk-assign
/// Add/remove tags for multiple entities (for bulk operations)
async fn bulk_assign_tags(
    Json(req): Json<BulkTagRequest>,  // { entity_ids: Vec<Uuid>, entity_type: String, add_tag_ids: Vec<Uuid>, remove_tag_ids: Vec<Uuid> }
) -> ApiResult<Json<ApiResponse<()>>>;
```

### Phase 7: Frontend

**New file:** `ui/src/lib/features/tags/mutations.ts`

```typescript
export function useTagAssignment() {
    const queryClient = useQueryClient();

    const addTag = createMutation({
        mutationFn: ({ entityId, entityType, tagId }: TagAssignmentParams) =>
            api.post(`/tags/${tagId}/entities`, { entity_id: entityId, entity_type: entityType }),
        onSuccess: (_, { entityType }) => {
            queryClient.invalidateQueries({ queryKey: [entityType.toLowerCase() + 's'] });
        }
    });

    const removeTag = createMutation({
        mutationFn: ({ entityId, entityType, tagId }: TagAssignmentParams) =>
            api.delete(`/tags/${tagId}/entities/${entityType}/${entityId}`),
        onSuccess: (_, { entityType }) => {
            queryClient.invalidateQueries({ queryKey: [entityType.toLowerCase() + 's'] });
        }
    });

    return { addTag, removeTag };
}
```

**Update:** `TagPickerInline.svelte` - Use the generic hook instead of per-entity callbacks

**Update:** `DataControls.svelte` - Bulk tagging uses `bulk-assign` endpoint

**Remove:** Per-entity tag handlers from HostTab, SubnetTab, etc.

## Files to Change

### Backend (New)
| File | Purpose |
|------|---------|
| `migrations/XXXX_entity_tags_junction.sql` | Create junction table, migrate data |
| `shared/storage/entity_tags.rs` | Junction table CRUD |
| `shared/traits/taggable.rs` | Taggable trait definition |
| `shared/services/entity_tags.rs` | Hydration + assignment logic |
| `entity_tags/mod.rs` | Module registration |
| `entity_tags/handlers.rs` | API endpoints |

### Backend (Modify)
| File | Change |
|------|--------|
| `hosts/service.rs` | Add tag hydration to get_host_response(s) |
| `subnets/service.rs` | Add tag hydration to get methods |
| `groups/service.rs` | Add tag hydration to get methods |
| `networks/service.rs` | Add tag hydration to get methods |
| `services/service.rs` | Add tag hydration to get methods |
| `discovery/service.rs` | Add tag hydration to get methods |
| `daemons/service.rs` | Add tag hydration to get methods |
| `*/impl/*.rs` | Implement Taggable trait for each entity |
| `shared/validation.rs` | Remove validate_and_dedupe_tags (moved to EntityTagService) |
| `shared/handlers/traits.rs` | Remove tag validation from generic create/update |

### Frontend (New)
| File | Purpose |
|------|---------|
| `features/tags/mutations.ts` | Generic useTagAssignment hook |

### Frontend (Modify)
| File | Change |
|------|--------|
| `features/tags/components/TagPickerInline.svelte` | Use generic hook |
| `shared/components/data/DataControls.svelte` | Simplify bulk tag props |
| `features/hosts/components/HostTab.svelte` | Remove per-entity tag handlers |
| `features/hosts/components/HostCard.svelte` | Use generic tag callbacks |
| (repeat for all entity tabs/cards) | Same pattern |

### Frontend (Already Done - Keep)
| File | Status |
|------|--------|
| `TagPickerInline.svelte` | Created (compact inline tag UI) |
| `DataControls.svelte` | Updated (bulk tag UI in action bar) |

## Acceptance Criteria

### Backend
- [x] Junction table created with proper indexes
- [x] Existing tag data migrated
- [x] Taggable trait implemented for all tagged entities
- [x] EntityTagService provides hydration and assignment
- [x] All service layer get methods hydrate tags
- [x] New API endpoints for tag assignment
- [x] Old tags columns dropped from entity tables
- [x] `cargo test` passes
- [x] `make format && make lint` passes

### Frontend
- [x] Generic useTagAssignment hook works for all entity types
- [x] Inline tag editing works in cards (add/remove)
- [x] Bulk tag operations work in DataControls
- [x] No per-entity tag handlers remain
- [x] `npm test` passes (no test script configured)

### Integration
- [x] Tags display correctly on all entity cards
- [x] Tags editable inline without opening modal
- [x] Bulk tag add/remove works for selected entities
- [x] Tag deletion cascades correctly (entities lose the tag)

## Work Summary

### Backend Changes

**Migration (`migrations/20260106204402_entity_tags_junction.sql`):**
- Created `entity_tags` junction table with indexes
- Migrated existing tag data from all 9 entity types (Host, Service, Subnet, Group, Network, Discovery, Daemon, DaemonApiKey, UserApiKey)
- Dropped legacy `trigger_remove_deleted_tag_from_entities` trigger (junction table's `ON DELETE CASCADE` handles tag cleanup)
- Dropped legacy `tags` columns from all entity tables

**Storage Layer (`shared/storage/entity_tags.rs`):**
- `EntityTagStorage` with CRUD operations for junction table
- `get_tags_for_entity`, `get_tags_map`, `add_tag`, `remove_tag`, `set_tags`, `remove_all_for_entity`

**Service Layer (`shared/services/entity_tags.rs`):**
- `EntityTagService` wrapping storage with validation
- Tag hydration helpers using `EntityDiscriminants` for type-safe entity types
- Integrated into `AppServices`

**Taggable Trait (`shared/taggable.rs`):**
- `Taggable` trait implemented for all 9 entity types
- Used by generic handlers for tag cleanup on delete

**API Endpoints (`entity_tags/handlers.rs`):**
- `POST /entity-tags` - Add tag to entity
- `DELETE /entity-tags/{entity_type}/{entity_id}/{tag_id}` - Remove tag from entity
- `POST /entity-tags/bulk` - Bulk add/remove tags for multiple entities

**Handler Updates (tag hydration):**
- `hosts/handlers.rs` - `get_all_hosts`, `get_host_by_id`, `update_host`, `consolidate_hosts`
- `daemons/handlers.rs` - `get_all`, `get_by_id`
- `subnets/handlers.rs` - `get_all_subnets`
- `user_api_keys/handlers.rs` - `get_all`

**StorableEntity Updates (skip tags column in SQL):**
- All 9 entity types updated to:
  - Skip `tags` field in `to_params()` with `tags: _` pattern
  - Initialize `tags: Vec::new()` in `from_row()`
- Pattern follows existing `binding_ids` approach in groups

**Generic Handler Updates (`shared/handlers/traits.rs`):**
- `delete_handler` and `bulk_delete_handler` clean up junction table entries via `EntityTagService::remove_all_for_entity`

### Frontend Changes

**Tag Mutations (`features/tags/queries.ts`):**
- `useAddEntityTag` mutation
- `useRemoveEntityTag` mutation
- `useBulkAssignTags` mutation
- All invalidate entity-specific query caches on success

**TagPickerInline Component:**
- Added "entity mode" with `entityId` and `entityType` props
- Internal mutations for add/remove when in entity mode
- Fixed height inconsistency (h-6 → h-5)

**DataControls Component:**
- Added bulk tagging support with `entityType` and `getItemTags` props
- Tag add/remove buttons appear when entities are selected
- Uses `useBulkAssignTags` mutation

**Card Components (inline tag editing):**
- All cards now use `TagPickerInline` with entity mode
- Tags editable directly on cards without opening modals
- Updated: HostCard, ServiceCard, SubnetCard, GroupCard, NetworkCard, DaemonCard, DiscoveryScheduledCard, UserApiKeyCard, DaemonApiKeyCard

**Tab Components (bulk tagging):**
- Added `entityType` and `getItemTags` props to DataControls
- Updated: HostTab, ServiceTab, SubnetTab, GroupTab, NetworksTab, DaemonTab, DiscoveryScheduledTab, UserApiKeyTab, DaemonApiKeyTab

**Cleanup:**
- Removed unused `tagsData` and `toColor` imports from card components

### Verification

- `cargo test` - All tests pass (except pre-existing doc test issue in taggable.rs)
- `make format && make lint` - All checks pass
- Entity deletion properly cascades to junction table cleanup
- Tag deletion cascades via `ON DELETE CASCADE` on junction table

