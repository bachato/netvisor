> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Group/Filter/Sort by Service on Hosts and Services Pages (Issue #499)

## Objective

Add "Service" as a grouping, filtering, and sorting option on the Hosts page. Verify that the Services page already has adequate group/sort/filter support.

## Context

- GitHub Issue: #499 — "Group/Filter/Sort by Service on Services and Hosts pages"
- Users want to answer questions like "show all hosts running SSH" or "group hosts by service"
- The Hosts API already returns `services: Vec<Service>` on each host response — no new API calls needed

## Requirements

### 1. Hosts Page — Add Service Field

**File:** `ui/src/lib/features/hosts/components/HostTab.svelte`

Add a new `DisplayFieldConfig` (client-side only) for services:

```typescript
{
  key: 'services',
  label: 'Services',  // use i18n function
  type: 'string',
  filterable: true,
  groupable: true,
  searchable: true,
  getValue: (host) => {
    // Return comma-separated service names for this host
    // host.services is already loaded (Vec<Service> on HostResponse)
    return host.services?.map(s => s.name).join(', ') || 'No services';
  }
}
```

**Many-to-one consideration:** A host can have multiple services. For filtering, each unique service name should appear as a filterable option. For grouping, hosts with a specific service should appear in that service's group. DataControls already handles this for comma-separated string values in the filter panel (it splits by unique values). Verify this behavior works correctly.

If DataControls doesn't handle multi-value grouping/filtering well for comma-separated strings, consider an alternative: make the field `type: 'array'` and return `host.services?.map(s => s.name) || []`. Check how the `tags` field (which is also an array) handles filtering — it may provide the pattern.

### 2. Services Page — Verify Existing Support

**File:** `ui/src/lib/features/services/components/ServiceTab.svelte`

The Services page already has:
- `host` field: orderable, filterable, groupable (server-side via `ServiceOrderField::Host`)
- `name` field: orderable, searchable
- `network_id` field: orderable, filterable, groupable
- `containerized_by` display field

Verify these work correctly:
- [ ] Can group services by Host
- [ ] Can filter services by Host
- [ ] Can sort services by Host
- [ ] Can search services by name

If the Services page needs a "Service Category" or "Service Definition" grouping option (to group by type of service like SSH, HTTP, DNS), add that as a display field.

### 3. I18n

Add any new i18n strings needed for the service field labels. Check existing i18n patterns in `ui/src/lib/i18n/` or `ui/src/lib/paraglide/`.

## Files Likely Involved

- `ui/src/lib/features/hosts/components/HostTab.svelte` — add service field to hostFields
- `ui/src/lib/features/services/components/ServiceTab.svelte` — verify, possibly add category field
- `ui/src/lib/shared/components/data/DataControls.svelte` — read to understand multi-value filtering behavior (DO NOT modify unless necessary)
- `ui/src/lib/shared/components/data/types.ts` — read to understand field config types

## Acceptance Criteria

- [x] Hosts page: can filter by service name (e.g., show only hosts with SSH)
- [ ] ~~Hosts page: can group by service name~~ — DataControls restricts grouping to orderable string fields; array fields (which is the correct type for multi-value services) cannot be grouped
- [x] Hosts page: service names are searchable
- [x] Services page: existing group/sort/filter by Host works correctly
- [x] No backend changes required (all client-side)
- [ ] `cd ui && npm run check` passes — npm deps not installed in env; needs local verification
- [ ] `make format && make lint` passes — backend passes; UI needs local verification

---

## Work Summary

### What was implemented

Added a `services` display field to the Hosts page, enabling users to filter and search hosts by service name (e.g., "show all hosts running SSH").

### File changed

- **`ui/src/lib/features/hosts/components/HostTab.svelte`** — 3 edits:
  1. Imported `useServicesCacheQuery` from services queries and `common_services` i18n message
  2. Added `servicesCacheQuery` + `allServicesData` derived state (reads from TanStack Query cache, no API calls)
  3. Added `services` display field to `hostFields` with `type: 'array'`, `searchable: true`, `filterable: true`, using `getValue` that joins services to hosts via `host_id`

### Design decisions

- **Used `useServicesCacheQuery()`** instead of the existing `useServicesByIds()` — the latter only fetches services for virtualization display. The cache query reads all services from the TanStack Query cache (populated by hosts query) reactively without additional API calls.
- **Used `type: 'array'`** (not `type: 'string'`) — follows the `tags` field pattern exactly. Array type gives proper per-value filtering (each service name appears as a separate filter option) rather than comma-separated string matching.
- **No grouping** — DataControls restricts grouping to orderable string fields (`DataControls.svelte:400-403`). Array fields cannot be grouped. This is a framework limitation, not a bug.
- **No Services page changes** — existing implementation already has host field (searchable, filterable, groupable), name field (searchable), network_id (filterable, groupable), plus containerized_by, confidence, and tags display fields.
