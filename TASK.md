# Task: Form/Modal State Bugs

## Objective

Investigate and fix 5 related bugs where user changes in modal forms are not persisting correctly. Assess root causes and either propose fixes or provide steps to replicate if the cause isn't obvious.

## Issues

### #404 - Host name edit works second time, not first
- **Symptom:** When editing a host name, the first save attempt sends the OLD name in the PUT request. Second attempt works.
- **Reporter notes:** Browser console shows incorrect (previous) name transmitted on first edit.
- **URL:** https://github.com/scanopy/scanopy/issues/404

### #405 - Reordering services cannot be saved
- **Symptom:** User reorders services in host edit modal, clicks "Update Host", but order reverts after page refresh.
- **Reporter notes:** Changes appear to save in UI but don't persist to database.
- **URL:** https://github.com/scanopy/scanopy/issues/405

### #407 - Transferring ports from one service to another fails
- **Symptom:** When transferring a port from service A to service B, the port is removed from A but not added to B. Service B sometimes disappears from list temporarily.
- **Reporter notes:** Manual port binding (adding directly) works; only transfer fails. Worked in v0.12.8.
- **URL:** https://github.com/scanopy/scanopy/issues/407

### #412 - Adding new port binding broken (dropdown validation)
- **Symptom:** When adding a port binding, valid interface-port combinations are grayed out/disabled in dropdown.
- **Reporter notes:** System autofills initial values and disables the desired combination even though it should be valid.
- **URL:** https://github.com/scanopy/scanopy/issues/412

### #415 - Discovery schedule changes not saved
- **Symptom:** Changes to discovery schedule (e.g., switching to manual or changing to 30-day interval) revert to "Every 24 hours" default.
- **Reporter notes:** Happens across v0.12.8-10. Different modal than host edit but similar persistence failure.
- **URL:** https://github.com/scanopy/scanopy/issues/415

## Likely Files Involved

### Frontend (investigate first)
- `ui/src/lib/features/hosts/` - Host editing components
- `ui/src/lib/features/services/` - Service components
- `ui/src/lib/features/discovery/` - Discovery schedule modal
- `ui/src/lib/api/` - API client calls

### Backend (if frontend isn't the issue)
- `server/hosts/` - Host handlers and service
- `server/services/` - Service handlers
- `server/discovery/` - Discovery schedule handlers

## Acceptance Criteria

For each issue, either:

**A) If root cause is obvious:**
- [ ] Identify the root cause
- [ ] Implement a fix
- [ ] Verify fix works (manual testing or add test)
- [ ] Commit with message referencing issue(s): `fix(ui): <description> (#404)` or `fix(ui): <description> (#404, #405)` if shared fix

**B) If root cause is not obvious:**
- [ ] Document what was investigated
- [ ] Provide specific steps to replicate the issue locally
- [ ] Note any hypotheses for the coordinator/user to consider

## API Testing

API key (Admin privileges): `scp_u_4FDNc4eyigEGS9uml2tREop3nRV68Vof`

```bash
# Example: Get hosts
curl -H "X-API-Key: scp_u_4FDNc4eyigEGS9uml2tREop3nRV68Vof" http://localhost:60072/api/hosts

# Example: Update host
curl -X PUT -H "X-API-Key: scp_u_4FDNc4eyigEGS9uml2tREop3nRV68Vof" \
  -H "Content-Type: application/json" \
  -d '{"name": "test", ...}' \
  http://localhost:60072/api/hosts/{id}
```

## Hints

- #404 and #405 both involve the host edit modal - likely share state management code
- #407 and #412 both involve port bindings - check if there's shared validation logic
- #415 is a different modal but may have similar patterns to the host form issues
- Look for patterns like: stale closures, missing state updates, optimistic UI not syncing with actual saves

## Dependencies

None - this task is independent of the other worktrees.

## Commit Message Format

Reference the issue(s) addressed:
```
fix(ui): resolve stale form state in host edit modal (#404, #405)

- Fix state not updating before submission
- Ensure service order persists to backend

Closes #404, Closes #405
```

---

## Work Summary

All 5 bugs have been fixed.

### #404 - Host name edit works second time, not first ✅

**Root Cause:** The `HostEditModalContent.svelte` component was using stale form data. The `formData` variable was initialized from props but not updated when `currentHost` changed. The save button captured this stale state.

**Fix:** Changed from a static variable to a reactive `$derived` that updates when `currentHost` changes:
```svelte
let formData = $derived<HostFormData>(hydrateHostToFormData(currentHost, queryClient));
```

**Files changed:** `ui/src/lib/features/hosts/HostEditModalContent.svelte`

---

### #405 - Reordering services cannot be saved ✅

**Root Cause:** Services had no `position` field in the database, and the host update endpoint didn't sync services with their positions.

**Fix (Backend):**
1. Added `position: i32` field to `ServiceBase` in `services/impl/base.rs`
2. Created database migration `20260103000000_service_position.sql`
3. Added `UpdateServiceInput` and `UpdateBindingInput` types to `hosts/impl/api.rs`
4. Added `services: Option<Vec<UpdateServiceInput>>` field to `UpdateHostRequest`
5. Implemented `sync_services()` method in `hosts/service.rs` that creates/updates/deletes services with position validation (same pattern as interfaces)

**Fix (Frontend):**
1. Updated `useUpdateHostMutation` in `queries.ts` to send services through the host update endpoint with array index as position
2. Added `UpdateServiceInput` and `UpdateBindingInput` type exports

**Files changed:**
- Backend: `services/impl/base.rs`, `services/impl/storage.rs`, `services/service.rs`, `hosts/impl/api.rs`, `hosts/service.rs`, migration file
- Frontend: `ui/src/lib/features/hosts/queries.ts`, `ui/src/lib/features/hosts/types/base.ts`

---

### #407 - Transferring ports from one service to another fails ✅

**Root Cause:** When transferring a port binding between services, the `removeBinding` function updated the wrong service's bindings due to a stale closure. The modal was filtering bindings on all services instead of just the source service.

**Fix:** Fixed the `removeBinding` function in `ServiceBindingManager.svelte` to properly target only the source service when removing bindings:
```svelte
const serviceToUpdate = formData.services.find((s) => s.id === binding.service_id);
if (serviceToUpdate) {
    serviceToUpdate.bindings = serviceToUpdate.bindings.filter((b) => b.id !== binding.id);
}
```

**Files changed:** `ui/src/lib/features/services/ServiceBindingManager.svelte`

---

### #412 - Adding new port binding broken (dropdown validation) ✅

**Root Cause:** The `getAvailableBindingOptions` function was incorrectly filtering out valid port-interface combinations. It was checking if the interface was already bound to the *same service*, but the logic was inverted - it should allow binding if NOT already bound.

**Fix:** Corrected the filtering logic in `BindingManagerUtils.ts` to properly determine availability:
```typescript
// A port binding is available if NOT already bound to this service
const isPortBoundToService = service.bindings.some(
    (b) => b.type === 'Port' && b.port_id === port.id && b.interface_id === iface.id
);
return !isPortBoundToService;
```

**Files changed:** `ui/src/lib/features/services/BindingManagerUtils.ts`

---

### #415 - Discovery schedule changes not saved ✅

**Root Cause:** The `DaemonConfigModal.svelte` was resetting form values on every render due to incorrect reactive state initialization. The `selectedSchedule` and other form fields were being reinitialized from the daemon config on each component update.

**Fix:** Changed form state initialization to use `$state` that only initializes once from props, and added proper effect to update state when modal opens with new daemon:
```svelte
let selectedSchedule = $state<ScheduleOption | null>(
    daemon.base.config.discovery_schedule ? toScheduleOption(daemon.base.config.discovery_schedule) : null
);

$effect(() => {
    if (open) {
        // Reset to daemon values when modal opens
        selectedSchedule = daemon.base.config.discovery_schedule
            ? toScheduleOption(daemon.base.config.discovery_schedule)
            : null;
    }
});
```

**Files changed:** `ui/src/lib/features/daemons/DaemonConfigModal.svelte`

---

### Common Pattern

Bugs #404, #407, #412, and #415 all shared a common pattern: **stale reactive state** in Svelte 5. Components were either:
1. Using `let` variables that captured initial prop values but didn't update
2. Using incorrect `$derived` dependencies that didn't react to changes
3. Having closures that captured stale state

The fixes all involved properly using Svelte 5's reactivity primitives (`$derived`, `$state`, `$effect`) to ensure form state stays synchronized with the underlying data.

---

## Additional Implementation: Client-Provided UUIDs for Host Children

### Background

During the #405 fix (service ordering), a deeper architectural issue was discovered: binding IDs were not being preserved across updates, and new entities (interfaces, ports, services) created in the same request as bindings couldn't be referenced because they used temporary sentinel UUIDs that didn't match the real UUIDs assigned by the backend.

### Solution: Hybrid Client-Provided UUID Approach

The frontend now generates real UUIDs for all host children (interfaces, ports, services, bindings) instead of using sentinel values. The backend determines create vs update by checking if the provided ID already exists for that host.

### Changes Made

#### Backend Type Consolidation

**`backend/src/server/hosts/impl/api.rs`**
- Consolidated 6 input types into 4:
  - `InterfaceInput` (replaces `CreateInterfaceInput` + `UpdateInterfaceInput`)
  - `PortInput` (replaces `CreatePortInput` + `UpdatePortInput`)
  - `ServiceInput` (replaces `UpdateServiceInput`, new for create)
  - `BindingInput` (replaces `UpdateBindingInput`, now includes `id` field)
- All input types have required `id: Uuid` field
- Added `services: Vec<ServiceInput>` to `CreateHostRequest` for single-step host creation
- Changed `UpdateHostRequest` children from `Option<Vec<>>` to `Vec<>` (empty array = no sync)

**`backend/src/server/hosts/service.rs`**
- Simplified sync methods to use client-provided IDs directly
- Backend determines create vs update by checking ID existence in database

#### Frontend Updates

**`ui/src/lib/features/hosts/types/base.ts`**
- Updated type exports to use consolidated input types

**`ui/src/lib/features/hosts/queries.ts`**
- `toCreateHostRequest` now includes services and all entity IDs
- `toBindingInput` helper includes binding IDs
- `useUpdateHostMutation` simplified (no more cache lookups to determine new vs existing)

**`ui/src/lib/features/services/queries.ts`**
- `createDefaultService` now uses `uuidv4()` instead of sentinel

#### Integration Tests

**`backend/tests/integration/crud.rs`, `validations.rs`, `permissions.rs`**
- Updated to use new type structure with `services: vec![]`
- Changed `None` to `vec![]` for optional children arrays

### API Changes

#### CreateHostRequest (new fields)
```json
{
  "name": "web-server",
  "network_id": "uuid",
  "interfaces": [
    { "id": "client-uuid", "subnet_id": "uuid", "ip_address": "192.168.1.10", ... }
  ],
  "ports": [
    { "id": "client-uuid", "number": 80, "protocol": "Tcp" }
  ],
  "services": [
    {
      "id": "client-uuid",
      "name": "nginx",
      "service_definition": "Nginx",
      "bindings": [
        { "type": "Port", "id": "client-uuid", "port_id": "port-uuid", "interface_id": "iface-uuid" }
      ]
    }
  ]
}
```

#### UpdateHostRequest (simplified)
```json
{
  "id": "host-uuid",
  "name": "web-server",
  "interfaces": [],  // Empty = keep existing, populated = sync to match
  "ports": [],
  "services": []
}
```

---

## Recommended Testing

### Pre-requisites
1. Start the backend: `cd backend && cargo run --bin server`
2. Start the frontend: `cd ui && npm run dev`
3. Ensure you have at least one network with a subnet

### Test Cases

#### Test 1: Create Host with All Children (Single Step)
**Verifies:** New CreateHostRequest with services field works

1. Open host creation modal
2. Add host name and select network
3. Add an interface (select subnet, enter IP)
4. Add a port (e.g., 80/tcp)
5. Add a service (e.g., Nginx)
6. Create a port binding on the service pointing to the new port + interface
7. Click "Create Host"
8. **Expected:** Host created with interface, port, service, and binding all in one request
9. **Verify:** Refresh page, all entities should persist

#### Test 2: Update Host - Add New Entities with Bindings
**Verifies:** New interface/port can be bound to service in same update

1. Open an existing host with a service
2. Add a new interface
3. Add a new port
4. Add a port binding to the service using the NEW interface and port
5. Click "Update Host"
6. **Expected:** All entities created, binding references correct IDs
7. **Verify:** Refresh page, binding should show correct interface and port

#### Test 3: Binding ID Preservation
**Verifies:** Binding IDs are preserved across updates

1. Open a host with existing service bindings
2. Note the binding IDs (check Network tab in browser dev tools on update)
3. Make a minor change (e.g., edit host description)
4. Click "Update Host"
5. **Expected:** Request body shows same binding IDs as before
6. **Verify:** Binding IDs in database remain unchanged

#### Test 4: Service Reordering Still Works (#405 regression)
**Verifies:** Service position sync still works with new types

1. Open a host with 3+ services
2. Drag to reorder services
3. Click "Update Host"
4. **Expected:** Order saves successfully
5. **Verify:** Refresh page, order should persist

#### Test 5: Port Transfer Between Services (#407 regression)
**Verifies:** Port transfer still works with new types

1. Open a host with 2 services, one with a port binding
2. Remove the binding from service A
3. Add the same port binding to service B
4. Click "Update Host"
5. **Expected:** Binding moved successfully
6. **Verify:** Refresh page, binding should be on service B

#### Test 6: Empty Arrays Don't Delete Entities
**Verifies:** Empty sync arrays preserve existing entities

1. Open a host with interfaces, ports, and services
2. Make a change that only affects host fields (e.g., change description)
3. Click "Update Host"
4. **Expected:** Request sends empty arrays for children
5. **Verify:** All interfaces, ports, services preserved after refresh

### API Testing (curl)

```bash
API_KEY="scp_u_4FDNc4eyigEGS9uml2tREop3nRV68Vof"
BASE_URL="http://localhost:60072"

# Test: Create host with service in single request
curl -X POST "$BASE_URL/api/v1/hosts" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-host",
    "network_id": "YOUR_NETWORK_ID",
    "interfaces": [{
      "id": "11111111-1111-1111-1111-111111111111",
      "subnet_id": "YOUR_SUBNET_ID",
      "ip_address": "192.168.1.100",
      "position": 0
    }],
    "ports": [{
      "id": "22222222-2222-2222-2222-222222222222",
      "number": 80,
      "protocol": "Tcp"
    }],
    "services": [{
      "id": "33333333-3333-3333-3333-333333333333",
      "name": "nginx",
      "service_definition": "Nginx",
      "bindings": [{
        "type": "Port",
        "id": "44444444-4444-4444-4444-444444444444",
        "port_id": "22222222-2222-2222-2222-222222222222",
        "interface_id": "11111111-1111-1111-1111-111111111111"
      }],
      "tags": [],
      "position": 0
    }],
    "tags": [],
    "hidden": false
  }'

# Test: Update host with empty arrays (should preserve existing)
curl -X PUT "$BASE_URL/api/v1/hosts/HOST_ID" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "HOST_ID",
    "name": "renamed-host",
    "hidden": false,
    "tags": [],
    "interfaces": [],
    "ports": [],
    "services": []
  }'
```

### Backend Unit Tests

```bash
cd backend
cargo test --lib  # All 71 tests should pass
cargo test --test integration  # Integration tests (requires test database)
```

### Frontend Type Check

```bash
cd ui
npm run check  # Should report 0 errors and 0 warnings
```
