> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Topology Default Visibility — OpenPorts Hidden, HostVirtualization Default-Hidden

## Objective

Two changes to topology default visibility settings:
1. Make **OpenPorts** default hidden as a service category
2. Make **HostVirtualization** default hidden as an edge type — but **user-togglable** instead of hard-coded hidden

## Requirements

### 1. OpenPorts — Default Hidden Service Category

Add `"OpenPorts"` to the `hide_service_categories` default array.

**Frontend:**
- **File:** `ui/src/lib/features/topology/queries.ts` (~line 34)
- Change `hide_service_categories: []` to `hide_service_categories: ['OpenPorts']`

**Backend:**
- **File:** `backend/src/server/topology/types/base.rs` (~line 258)
- Change `hide_service_categories: Vec::new()` to `hide_service_categories: vec![ServiceCategory::OpenPorts]`
- Verify `ServiceCategory::OpenPorts` exists in the enum — check `backend/src/server/topology/types/` or the service definition types

**Note:** The `hide_service_categories` array is used server-side to filter services from topology responses. The backend default must match the frontend default.

### 2. HostVirtualization — Default Hidden (Not Hard-Coded)

Currently, HostVirtualization edges are **hard-coded to be filtered out** in the visualization layer, meaning users cannot show them even if they toggle the option.

**Step A — Remove the hard-coded filter:**
- **File:** `ui/src/lib/features/topology/components/visualization/BaseTopologyViewer.svelte` (~line 182)
- Current code:
  ```typescript
  const flowEdges: Edge[] = topology.edges
      .filter((edge) => edge.edge_type != 'HostVirtualization')
      .map(...)
  ```
- Change to: Remove the `.filter((edge) => edge.edge_type != 'HostVirtualization')` line entirely. Let the existing `hide_edge_types` option system control visibility instead.

**Step B — Add HostVirtualization to default `hide_edge_types`:**
- **File:** `ui/src/lib/features/topology/queries.ts` (~line 20)
- Change `hide_edge_types: []` to `hide_edge_types: ['HostVirtualization']`

**Result:** HostVirtualization edges are hidden by default (same visual behavior as before), but users can now toggle them visible via the Options panel → "Hide Edge Types" multiselect. The edge type option was already present in the UI but non-functional due to the hard-coded filter.

**Important:** Verify that the `CustomEdge.svelte` component correctly handles the `hide_edge_types` option for HostVirtualization (it should — line ~88-90 already checks `$topologyOptions.local.hide_edge_types.includes(edgeData.edge_type)`). Also verify that the selection/highlighting logic in `interactions.ts` (lines ~236-240, ~284-287) still works — it uses HostVirtualization edges for highlighting connected VMs when a hypervisor is selected. This highlighting should continue to work regardless of visibility.

## Edge Cases

- **Existing users:** Users who have saved topology options in localStorage will have their own `hide_edge_types` and `hide_service_categories` arrays that override defaults (deepmerge with array override). These users won't see the new defaults — that's correct behavior (they've customized their view).
- **New users / cleared localStorage:** Will see the new defaults (OpenPorts hidden, HostVirtualization edges hidden but togglable).

## Files Likely Involved

- `ui/src/lib/features/topology/queries.ts` — default options
- `ui/src/lib/features/topology/components/visualization/BaseTopologyViewer.svelte` — remove hard-coded filter
- `backend/src/server/topology/types/base.rs` — backend default options
- Verify (read only): `ui/src/lib/features/topology/components/visualization/CustomEdge.svelte`, `ui/src/lib/features/topology/interactions.ts`

## Acceptance Criteria

- [x] OpenPorts service category is hidden by default in new topology views
- [x] HostVirtualization edges are hidden by default in new topology views
- [x] HostVirtualization edges can be toggled visible via Options → Hide Edge Types
- [x] When HostVirtualization edges are shown, they render correctly
- [x] Selection highlighting still works for hypervisor → VM connections
- [x] Hard-coded `.filter((edge) => edge.edge_type != 'HostVirtualization')` is removed
- [x] Backend and frontend defaults match
- [x] `cd backend && cargo test` passes
- [x] `cd ui && npm run check` passes
- [x] `make format && make lint` passes

---

## Work Summary

### What was implemented

Changed topology default visibility so OpenPorts services and HostVirtualization edges are hidden by default, and removed the hard-coded HostVirtualization filter so users can toggle it visible.

### Files changed

- **`ui/src/lib/features/topology/queries.ts`** — Added `'HostVirtualization'` to `hide_edge_types` default, `'OpenPorts'` to `hide_service_categories` default
- **`ui/src/lib/features/topology/components/visualization/BaseTopologyViewer.svelte`** — Removed `.filter((edge) => edge.edge_type != 'HostVirtualization')` hard-coded filter
- **`backend/src/server/topology/types/base.rs`** — Backend defaults: `hide_edge_types` → `vec![EdgeTypeDiscriminants::HostVirtualization]`, `hide_service_categories` → `vec![ServiceCategory::OpenPorts]`

### Verification

- `cargo test` — all pass
- `npm run check` (svelte-check) — 0 errors, 0 warnings
- `make format && make lint` — clean
