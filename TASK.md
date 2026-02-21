> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Add Group/Sort/Filter to 6 Entity Pages

## Objective

Enable group by, sort by, and filter functionality for Shares, Scheduled Discoveries, Historical Discoveries, Daemon API Keys, Networks, and Users. All these pages currently have display-only fields that don't appear in group/sort dropdowns.

## Context

- None of these entities are paginated on the frontend (all fetch with `limit: 0`)
- All changes are **frontend-only** — no backend OrderField enums needed
- DataControls already handles client-side sorting/grouping when no `onOrderChange` callback is provided
- The key change: convert `DisplayFieldConfig` fields to properly typed fields with `filterable`, `groupable`, `searchable` flags

## Requirements

### Understanding the Field System

Read these files first:
- `ui/src/lib/shared/components/data/types.ts` — `OrderableFieldConfig` vs `DisplayFieldConfig`, `defineFields()`
- `ui/src/lib/shared/components/data/DataControls.svelte` — how group/sort/filter dropdowns are populated

Currently, fields defined with just `key` (DisplayFieldConfig) don't appear in group/sort dropdowns. Fields need to be properly configured with `type`, `filterable`, `groupable` flags to appear.

**Important:** The `defineFields<T, O>()` helper enforces that ALL `OrderField` enum values are covered, which is for server-side ordering. Since we're doing client-side only, you may need to define fields manually or use a different approach. Study how existing pages that DON'T use `defineFields` set up their field configs, or check if DataControls supports grouping/sorting on display fields. If not, you may need to adjust DataControls to support client-side sorting on non-orderable fields.

### 1. Shares

**File:** `ui/src/lib/features/shares/components/ShareTab.svelte`

Fields to make groupable/sortable/filterable:
- `name` — string, searchable, sortable
- `network_id` — string, filterable, groupable (getValue: look up network name)
- `topology_id` — string, filterable (getValue: look up topology name)
- `is_enabled` — boolean, filterable
- `expires_at` — date, sortable
- `created_at` — date, sortable

### 2. Scheduled Discoveries

**File:** `ui/src/lib/features/discovery/components/tabs/DiscoveryScheduledTab.svelte`

Fields to make groupable/sortable/filterable:
- `name` — string, searchable, sortable
- `network_id` — string, filterable, groupable (getValue: look up network name)
- `daemon_id` — string, filterable, groupable (getValue: look up daemon name)
- `discovery_type` — string, filterable, groupable
- `created_at` — date, sortable

### 3. Historical Discoveries

**File:** `ui/src/lib/features/discovery/components/tabs/DiscoveryHistoryTab.svelte`

Fields to make groupable/sortable/filterable:
- `name` — string, searchable, sortable
- `network_id` — string, filterable, groupable
- `daemon_id` — string, filterable, groupable
- `status` — string, filterable, groupable (if available)
- `created_at` — date, sortable
- `completed_at` — date, sortable (if available)

### 4. Daemon API Keys

**File:** `ui/src/lib/features/daemon_api_keys/components/ApiKeyTab.svelte`

Fields to make groupable/sortable/filterable:
- `name` — string, searchable, sortable
- `network_id` — string, filterable, groupable (getValue: look up network name)
- `created_at` — date, sortable (if available on entity)

### 5. Networks

**File:** `ui/src/lib/features/networks/components/NetworksTab.svelte`

Fields to make groupable/sortable/filterable:
- `name` — string, searchable, sortable
- `tags` — array, filterable
- `created_at` — date, sortable (if available)

### 6. Users

**File:** `ui/src/lib/features/users/components/UserTab.svelte`

Fields to make groupable/sortable/filterable:
- `email` — string, searchable, sortable
- `permissions` — string, filterable, groupable
- `oidc_provider` — string, filterable, groupable
- `created_at` — date, sortable (if available)

## Implementation Approach

For each page:
1. Read the current field definitions
2. Understand what data is available on the entity (check the TypeScript types in `ui/src/lib/api/`)
3. Convert display-only fields to proper field configs with correct `type`, `filterable`, `groupable`, `searchable`, `getValue`
4. Ensure DataControls receives the updated fields and shows group/sort/filter controls
5. Test that sorting, grouping, and filtering work client-side

## Files Likely Involved

- 6 tab component files listed above
- `ui/src/lib/shared/components/data/DataControls.svelte` — may need to read; adjust only if needed for client-side sorting on non-orderable fields
- `ui/src/lib/shared/components/data/types.ts` — read for type definitions

## Acceptance Criteria

- [ ] All 6 pages show Group By dropdown with relevant string fields
- [ ] All 6 pages show Sort By dropdown with relevant fields
- [ ] All 6 pages show Filter options for relevant fields
- [ ] Grouping works correctly (items grouped under headers)
- [ ] Sorting works correctly (asc/desc)
- [ ] Filtering works correctly (checkbox-style for string values)
- [ ] Search works on name/email fields
- [ ] No backend changes needed
- [ ] `cd ui && npm run check` passes
- [ ] `make format && make lint` passes

## Work Summary

### What was implemented

Extended `DisplayFieldConfig` with opt-in `sortable` and `groupable` boolean flags, and updated `DataControls` to include these fields in Sort By / Group By dropdowns. Then applied these flags across 6 entity pages:

| Page | Sort By | Group By |
|------|---------|----------|
| Shares | name, expires_at, created_at | network_id |
| Scheduled Discoveries | name, created_at | daemon_id, network_id, discovery_type, run_type |
| Historical Discoveries | name, created_at | daemon_id, network_id, discovery_type |
| Daemon API Keys | name, created_at | network_id |
| Networks | name, created_at | — |
| Users | email, created_at | permissions, oidc_provider |

Also added a `network_id` field to `discoveryFields()` (shared between Scheduled and Historical tabs) with network name lookup, and `created_at` fields where missing.

### Files changed (10)

- `ui/src/lib/shared/components/data/types.ts` — Added `sortable`/`groupable` to `DisplayFieldConfig`, added `isDisplayField()` type guard
- `ui/src/lib/shared/components/data/DataControls.svelte` — Updated `groupableFields`/`sortableFields` derived values
- `ui/src/lib/features/discovery/queries.ts` — Updated `discoveryFields` signature to accept `networks`, added `network_id` field, added `sortable`/`groupable` flags
- `ui/src/lib/features/shares/components/ShareTab.svelte` — Added `sortable`/`groupable` flags
- `ui/src/lib/features/discovery/components/tabs/DiscoveryScheduledTab.svelte` — Added networks query, `created_at` field, `groupable` on `run_type`
- `ui/src/lib/features/discovery/components/tabs/DiscoveryHistoryTab.svelte` — Added networks query, `created_at` field
- `ui/src/lib/features/daemon_api_keys/components/ApiKeyTab.svelte` — Added `sortable`/`groupable` flags, `created_at` field
- `ui/src/lib/features/networks/components/NetworksTab.svelte` — Added `sortable` on name, `created_at` field
- `ui/src/lib/features/users/components/UserTab.svelte` — Added `sortable`/`groupable` flags, `created_at` field

### Verification

- `svelte-check`: 0 errors, 0 warnings
- `npm test`: 14/14 pass
- `eslint`: passes
- No backend changes
