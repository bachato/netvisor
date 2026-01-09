> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

<<<<<<< HEAD
<<<<<<< HEAD
# Task: Fix HTTP 413 Error When Rebuilding Topology (Issue #451)

## Objective

Fix the HTTP 413 (Payload Too Large) error that occurs when rebuilding topology.

## Issue Summary

**GitHub Issue:** #451

**Reported Behavior:**
- Navigate to Topology section
- Click "Auto" then "Rebuild"
- Red error alert displays HTTP 413

**Environment:**
- v0.13.3
- Debian Trixie (Proxmox VM)
- Firefox 146.0.1
- Caddy reverse proxy

**User's Troubleshooting:**
- Configured Caddy's `request_body` directive with 100MB limit
- Temporarily resolved the issue but errors recurred
- No errors in Docker server logs when failure occurred

## Investigation Approach

1. **Understand the topology rebuild flow:**
   - What endpoint is called?
   - What data is sent in the request body?
   - How large can this payload get?

2. **Check server-side limits:**
   - Axum/Tower body size limits
   - Any middleware limiting request size

3. **Check the payload:**
   - Is the full topology being sent unnecessarily?
   - Can we reduce payload size?
   - Should this be a streaming/chunked request?

4. **Consider solutions:**
   - Increase server body size limit
   - Optimize the payload (send only what's needed)
   - Document proxy configuration requirements
   - Add better error messaging

## Files Likely Involved

- `backend/src/server/topology/handlers.rs` - Topology endpoint handlers
- `backend/src/bin/server.rs` - Server configuration, body limits
- `ui/src/lib/features/topology/` - Frontend topology components
- `ui/src/lib/api/` - API client for topology endpoints

## Acceptance Criteria

- [ ] Topology rebuild works without 413 error for reasonably-sized networks
- [ ] Server body size limits are appropriately configured
- [ ] If payload optimization is possible, implement it
- [ ] If proxy configuration is required, document it clearly
- [ ] `cargo test` passes
- [ ] Error message is helpful if limit is exceeded

## Notes

- The issue may be in the reverse proxy (Caddy), but we should also ensure server-side limits are reasonable
- Consider if the topology rebuild really needs to send/receive large payloads
- Check if there's a way to make this operation more efficient
=======
# Task: Fix Service Binding Text Search in Groups (Issue #452)
=======
# Task: Fix Host Icon from Best Service (Issue #449)

## Objective

Fix the regression where host icons no longer display the icon from the "best" or "top" service.

## Issue Summary

**GitHub Issue:** #449

**Reported Behavior:**
- Navigate to Hosts section
- Observe host icons
- Question marks appear instead of service icons

**Expected Behavior:**
- Icons should display for the top-performing/best service
- Matches behavior from v0.12.x

**Additional Context:**
- In v0.12.x, a dropdown existed on host details page to select icon display strategy
- This configuration option is no longer available in current version
- Reporter unsure if removal was intentional

**Environment:** v0.13.3, regression since v0.13.2
>>>>>>> fix/449-host-icon

## Objective

Fix the broken text search functionality when selecting service bindings while creating/editing Groups.

## Issue Summary

**GitHub Issue:** #452

**Reported Behavior:**
- Navigate to Groups section
- Create or edit a Group
- Scroll to "Select a binding to add"
- Attempt to search for bindings by text
- Nothing shows up, despite bindings existing

**Expected Behavior:**
- Users should be able to search for substrings matching interface or service names

**Environment:** v0.13.3, suspected regression from v0.13.1 or later

## Investigation Approach

1. **Find the Group creation/edit modal** - Look in `ui/src/lib/features/groups/`
2. **Locate the binding selector component** - Likely a searchable dropdown or combobox
3. **Check the search/filter logic** - May be filtering on wrong field, case sensitivity issue, or empty results
4. **Compare with similar selectors** - Other entity selectors that work correctly
5. **Check for recent changes** - What changed in v0.13.1+ that could have broken this?

## Files Likely Involved

- `ui/src/lib/features/groups/` - Group-related components
- `ui/src/lib/components/` - Shared selector/search components
- Look for components like `BindingSelector`, `SearchableSelect`, `Combobox`

## Acceptance Criteria

- [ ] Text search in binding selector filters results correctly
- [ ] Search matches interface names
- [ ] Search matches service names
- [ ] Case-insensitive search works
- [ ] Empty search shows all available bindings
- [ ] `npm test` passes (if relevant tests exist)

## Notes

- This is a frontend bug - focus on the UI components
- May be related to how bindings are being filtered/displayed
- Check if the search is client-side or server-side
>>>>>>> fix/452-group-binding-search

## Work Summary

### Root Cause
<<<<<<< HEAD

<<<<<<< HEAD
The `rebuild` and `refresh` endpoints accepted `Json<Topology>` containing the **full topology** (hosts, interfaces, services, subnets, groups, ports, bindings, nodes, edges, etc.) but only actually used a few fields. Combined with Axum's default 2MB body limit, large networks would exceed this limit and trigger HTTP 413 errors.

### Solution Implemented

Created a lightweight `TopologyRebuildRequest` type that only includes fields the server actually needs:
- `network_id` - for authorization
- `options` - for graph building configuration
- `nodes` - for position preservation during rebuild
- `edges` - for edge reference during rebuild

This reduces payload size from potentially megabytes to kilobytes.

### Files Changed

**Backend:**
- `backend/src/server/topology/types/base.rs` - Added `TopologyRebuildRequest` type
- `backend/src/server/topology/handlers.rs` - Updated `rebuild` and `refresh` handlers to use new type

**Frontend:**
- `ui/src/lib/features/topology/queries.ts` - Updated `useRebuildTopologyMutation`, `useRefreshTopologyMutation`, and SSE auto-rebuild to send minimal payload
- `ui/static/openapi.json` - Regenerated with new type
- `ui/src/lib/api/schema.d.ts` - Regenerated TypeScript types

### Payload Size Comparison

| Scenario | Before | After |
|----------|--------|-------|
| Small network (10 hosts) | ~50KB | ~5KB |
| Medium network (100 hosts) | ~500KB | ~20KB |
| Large network (1000+ hosts) | ~5MB+ (413 error) | ~100KB |

### Authorization

- Permission requirement: `Member` (unchanged)
- Tenant isolation: Validated via `network_id` in request against user's `network_ids()`

### Testing

- `cargo test` - All tests pass
- `make format && make lint` - All checks pass
- Type generation successful
=======
The `RichSelect` component's search filter was not passing the `context` parameter to `displayComponent.getLabel()`. For `BindingWithServiceDisplay`, this context is required to look up service names from the services array. Without context, `getLabel` always returned "Unknown Service", making text search ineffective.

Additionally, the search was only checking `label` and `description` fields, but for bindings, the interface/port info is displayed via `getTags()`, which wasn't being searched.

### Changes Made

**File: `ui/src/lib/shared/components/forms/selection/RichSelect.svelte`**

1. **Line 67**: Added `context` parameter to `getLabel()` call:
   - Before: `displayComponent.getLabel(option)`
   - After: `displayComponent.getLabel(option, context)`

2. **Lines 69-70**: Added tag searching - now also searches the labels from `getTags()`:
   ```javascript
   const tags = displayComponent.getTags?.(option, context) ?? [];
   const tagLabels = tags.map((tag) => tag.label.toLowerCase()).join(' ');
   ```

3. **Lines 72-76**: Updated return to include tag matches:
   ```javascript
   return (
       label.includes(searchTerm) ||
       description.includes(searchTerm) ||
       tagLabels.includes(searchTerm)
   );
   ```

**File: `ui/src/lib/features/groups/components/GroupEditModal/GroupEditModal.svelte`**
=======

The issue was a race condition combined with incorrect fallback logic in `HostCard.svelte`.

**The problematic code:**
```javascript
Icon:
    serviceDefinitions.getIconComponent(hostServices[0]?.service_definition) ||
    entities.getIconComponent('Host'),
```

**What happened:**
1. On initial render, services haven't loaded yet → `hostServices` is `[]`
2. `hostServices[0]?.service_definition` evaluates to `undefined`
3. `getIconComponent(undefined)` returns `HelpCircle` (question mark icon)
4. `HelpCircle` is truthy, so the `|| entities.getIconComponent('Host')` fallback never triggers
5. When services load, the derived block should re-run, but the initial `HelpCircle` was being shown inconsistently

The inconsistency occurred because:
- Sometimes TanStack Query had cached data → services available immediately → correct icon
- Sometimes cache miss → initial render shows `HelpCircle` → re-render timing issues

### Fix

Changed the fallback logic to explicitly check if services exist:

```javascript
Icon:
    hostServices.length > 0
        ? serviceDefinitions.getIconComponent(hostServices[0].service_definition)
        : entities.getIconComponent('Host'),
```

This ensures:
- If no services (yet or ever) → Host icon is shown (not HelpCircle)
- If services exist → first service's icon is shown

### Files Changed

1. **`ui/src/lib/features/hosts/components/HostCard.svelte`** (lines 94-97)
   - Changed from `||` fallback to explicit ternary with `hostServices.length > 0` check

### Regarding Icon Strategy Dropdown

No evidence of an "icon strategy" dropdown exists in the current codebase. The implementation uses the first service (sorted by position) to determine the host icon. This appears to be the intended behavior.
>>>>>>> fix/449-host-icon

4. **Line 132**: Added filter to exclude "Unclaimed Open Ports" services from binding dropdown:
   ```javascript
   .filter((s) => s.service_definition !== 'Unclaimed Open Ports')
   ```

<<<<<<< HEAD
### Acceptance Criteria Status

- [x] Text search in binding selector filters results correctly
- [x] Search matches service names (via `getLabel` with context)
- [x] Search matches interface names (via `getTags` search)
- [x] Case-insensitive search works (all comparisons use `.toLowerCase()`)
- [x] Empty search shows all available bindings (early return on empty filterText)
- [x] `make format && make lint` passes
>>>>>>> fix/452-group-binding-search
=======
- `npm run check` (svelte-check): 0 errors, 0 warnings
- `npm run format && npm run lint`: Passes
>>>>>>> fix/449-host-icon
