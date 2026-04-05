# Future Perspectives Notes

## L2 Physical
- Could use `ByApplicationGroup` pattern for L2: group by VLAN tag or physical switch
- Physical link edges are already primary in L2 perspective
- Container rule: `BySwitch` or `ByVLAN` would be natural groupings
- **Element (interface port):** SectionIdentity shows the IfEntry data (physical port name, MAC, ifIndex). SectionIfEntryData shows full SNMP status, speed, and LLDP/CDP neighbor details. SectionTags for host tags.
- **Container:** SectionIdentity shows the VLAN or broadcast domain name. SectionElementSummary shows port count.
- **Edge inspector:** PhysicalLink edges should show source/target IfEntry details, discovery protocol (LLDP/CDP), and neighbor resolution details. The InspectorEdgePhysicalLink component already handles this.
- **ElementEntityType:** Would likely be `Interface` (same as L3) but resolved differently — matching IfEntry rather than IP interface.

## Cross-Perspective Platform Issues

These systems were built for L3 and need generalizing before additional perspectives work well.

### Element visibility/fading not perspective-aware

- **Generic service filter:** `updateTagFilter()` hides services via `tagHiddenServiceIds`, which only works for services-within-interface-nodes (L3). In Application, services ARE element nodes — need `tagHiddenNodeIds`. Partially addressed in `fix/topo-perspective-switching` but needs a unified approach.
- **Container selection fading:** Selecting a container should fade other containers but highlight elements inside the selected one. Works in L3 (interfaces in subnets) but broken in Application — selecting an ApplicationGroup fades its own service elements. The `connectedNodeIds` / selection fading logic assumes L3's Interface→Subnet parent structure.
- **Root cause:** The visibility system assumes L3's entity model (interfaces inside subnets, services as sub-items of interfaces). Application inverts this — services are top-level elements in app-group containers. Any code determining "which nodes belong to this container" or "which should be visible/faded" needs to work with any element-in-container relationship.

### Frontend perspective audit needed before adding perspectives

Before implementing Infrastructure or L2, audit the frontend to ensure perspective concerns are properly abstracted:

- **Perspective-specific logic in components:** Grep for hardcoded perspective string comparisons (`=== 'L3Logical'`, `=== 'Application'`) in components that should be reading from backend config/metadata instead. These are fragile — each new perspective requires touching every component with a comparison.
- **Frontend mappings that belong on the backend:** Check for any TypeScript objects/maps that duplicate backend metadata (section orderings, element type labels, entity type mappings). These should flow through the API / fixtures via `TypeMetadataProvider`.
- **L3 assumptions baked into shared code:** The visibility/fading, multi-select, and tag filter systems were built for L3. Audit `interactions.ts`, `resolvers.ts`, `ElementNode.svelte`, `ContainerNode.svelte` for code that assumes interfaces-in-subnets structure.
- **Inspector section components:** Verify each section component works generically with any element/container type, not just the ones it was built for.

This audit should produce a concrete list of changes needed, done as a single cleanup pass before the next perspective is built.

## Infrastructure
- `ByVirtualizingService` already applies to Infrastructure perspective
- Could add `ByHypervisor` container rule to group VMs under their hypervisor host
- Proxmox integration would feed into this naturally
- **Element (host/VM):** SectionIdentity shows the host with virtualization info. SectionServices shows services running on the host. SectionTags for host tags.
- **Container (hypervisor/cluster):** SectionIdentity shows the hypervisor service name and host. SectionElementSummary shows VM count.
- **Edge inspector:** HostVirtualization and ServiceVirtualization edges already have dedicated inspectors. These work well for Infrastructure perspective.
- **ElementEntityType:** May need a new `Host` variant or reuse `Interface` with different resolution logic. Alternatively, use `Service` where the element represents a VM service.
- **Key difference from L3:** Grouping is by virtualization hierarchy (hypervisor → VMs) rather than by subnet.

## Frontend Perspective Audit Findings

Completed audit (refactor/topo-perspective-audit branch). Bugs fixed, hardcoded comparisons eliminated. Remaining L3-specific code that needs refactoring for new perspectives:

### Container resolver assumes subnet entity
- **File:** `resolvers.ts:74-89` (`resolveContainer`)
- Has a TODO already. Returns a subnet entity for tag hover support. When containers represent other entity types (hosts, hypervisors), must return tags generically from whatever entity the container represents.
- **Fix:** Add a `containerEntityType` field to the container resolver context, and look up tags from the matching entity collection.

### Docker/virtualization hover logic is L3-specific
- **File:** `interactions.ts:193-252` (`updateConnectedNodes` Docker bridge section)
- Navigates host → interfaces → subnets to find Docker bridge subnets and connected container interfaces. Entirely L3-specific: uses `host_id`, `subnet_id`, `is_for_containers`.
- **Fix:** When adding Infrastructure perspective, this needs a perspective-aware hover expansion strategy. Could be driven by edge type classification — follow Primary edges to find connected nodes.

### `addBoundInterfaces()` is L3-specific binding logic
- **File:** `interactions.ts:523-556`
- Filters services by `binding.interface_id` and finds non-container host interfaces. Used by hover expansion to highlight related interfaces.
- **Fix:** Either make this conditional on perspective (only active for L3/L2) or extract a perspective-specific hover strategy.

### Service binding filtering in components
- **Files:** `ElementNode.svelte:155`, `InspectorElementNode.svelte:49`, `SectionServices.svelte:28-29`
- Filters services by `binding.interface_id` match — only meaningful for Interface elements in L3. Service elements in Application perspective handle this differently (direct service on the node).
- **Status:** Already gated by element type in practice (Service elements take a different render path in ElementNode.svelte:131-144), but the Interface path should be explicitly skipped for non-Interface element types when new types are added.

### Interface binding disambiguation in multi-select
- **File:** `InspectorMultiSelect.svelte:337-382`
- Builds interface binding choices for dependency creation disambiguation. Only applies to L3/L2 perspectives where elements are interfaces with multiple bindings.
- **Status:** Already correctly gated by `isServicesMode` (lines 680-724). No fix needed.

### `container_id ?? subnet_id` fallback pattern
- **Files:** `collapse.ts:124,143`, `layout-graph.ts:169`, `elk-layout.ts:156,215,653`
- Uses `container_id ?? subnet_id` to find element's parent container. The `subnet_id` fallback is L3-specific — once all perspectives consistently provide `container_id` on the backend, the fallback can be removed.
- **Fix:** Ensure backend graph builder always sets `container_id` for elements in all perspectives, then remove the `subnet_id` fallback.
