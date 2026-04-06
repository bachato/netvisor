# Topology: Infrastructure + L2 Perspectives + Data Collection

## Your Role

You are the coordinator for implementing the remaining topology perspectives (Infrastructure and L2 Physical) and the data collection work that enables advanced grouping rules. This work runs as parallel worktrees.

## Background

Read these documents first:

1. **UX Design Doc**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/planned-work/topology-visualization-redesign.md` — Key sections: Perspective 1 (L2 Physical), Perspective 3 (Infrastructure), the Perspective × C4 matrix, Edge Classification, Layout Engine (elkjs for Infrastructure, d3-force for L2), Inspector Panel.
2. **Project Instructions**: `/Users/maya/dev/scanopy/CLAUDE.md`
3. **Status Tracker**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/memory/project_topology_perspectives_status.md`

## Current State

L3 and Application perspectives are implemented. The platform is in place:

- `PerspectiveBuilder` trait — each perspective implements `create_containers`, `create_elements`, `create_edges`, etc.
- `LayoutEngine` interface — `ElkLayoutEngine` wraps elkjs. A second engine (d3-force) can be plugged in.
- Perspective-indexed `TopologyRequestOptions` — per-perspective option storage
- Container rules + element rules with `applicable_perspectives()` scoping
- Perspective-aware inspector panel with section-based model
- Perspective selector UI
- `ElementEntityType` with perspective-specific fields in variants

Study the L3Builder and ApplicationBuilder implementations to understand the patterns. Infrastructure and L2 should follow the same patterns.

---

## Batch B: Infrastructure Perspective

### InfrastructureBuilder

Implement `PerspectiveBuilder` for Infrastructure:

- **Containers:** Virtualizer hosts (Proxmox) and Docker hosts. Bare-metal hosts without virtualization grouped in a "Bare Metal" container.
- **Elements:** VMs and containers (as hosts). Each element shows the VM/container name and the platform (Proxmox/Docker).
- **Primary relationship:** Virtualization expressed as **containment** — VMs inside their hypervisor's container, Docker containers inside their Docker host's container. No drawn edges for virtualization. The nesting IS the relationship.
- **Primary edges:** None drawn by default. Virtualization is containment, not edges. PhysicalLink available as overlay (shows which physical switch ports carry virtualized traffic).
- **Layout:** elkjs compound layered (same as L3 and Application — no new layout engine needed).
- **Layout hints:** Virtualizers could be layered by type (Proxmox at one level, Docker hosts at another) or left unlayered for elkjs to optimize.

### ByVirtualizer container rule

New `ContainerRule` variant. `applicable_perspectives()` returns `[Infrastructure]`.

Groups elements by their virtualizing host:
- Proxmox VMs → grouped under their Proxmox host
- Docker containers → grouped under their Docker host
- Bare-metal services → ungrouped or in a default container

### Host-as-element

New `ElementEntityType` variant: `Host { host_id: Uuid }` or similar. In Infrastructure, the element IS a host (VM or container host), not an interface or service.

The resolver needs metadata for this variant — icon (VM vs container), label pattern, display fields.

### Inspector sections for Infrastructure

Following the section-based model from the inspector refactor:

| Inspecting | Primary info |
|---|---|
| Element (VM/container) | VM/container name, host, platform (Proxmox/Docker), services running inside, network interfaces |
| Container (hypervisor/Docker host) | Hostname, platform, VM/container count |

### Multi-select behavior in Infrastructure

- **Bulk tagging:** "You tag what you're looking at." Elements are VMs/containers (hosts) → bulk tag targets **hosts**.
- **Dependency creation:** Not available. Dependencies are service-level relationships — they belong in Application perspective.

### Data available

- `HostVirtualization` — Proxmox VM → virtualizer host mapping (vm_name, vm_id, service_id)
- `ServiceVirtualization` — Docker container → Docker host service mapping (container_name, container_id, service_id)
- `SubnetType::DockerBridge` — Docker bridge subnets

---

## Batch C: L2 Physical Perspective

### L2Builder

Implement `PerspectiveBuilder` for L2:

- **Containers:** Switches — hosts that have IfEntry records with SNMP data. A switch is identified by having LLDP/CDP neighbor data or significant IfEntry records.
- **Elements:** Ports (IfEntry records). Each element shows port name, status, speed.
- **Primary edges:** PhysicalLink (LLDP/CDP discovered connections). Labels show port pair (e.g., "Gi0/1 ↔ Gi0/2").
- **Overlay edges:** HostVirtualization (shows VM traffic paths). Off by default.
- **Layout:** **d3-force** (force-directed) — NOT elkjs. L2 is a peer-to-peer graph with no implied hierarchy. This requires implementing `ForceLayoutEngine`.

### ForceLayoutEngine

Implement the `LayoutEngine` interface using d3-force:

```typescript
class ForceLayoutEngine implements LayoutEngine {
    async compute(input: LayoutInput): Promise<LayoutResult>;
}
```

Key differences from ELK:
- No layer constraints (no hierarchy)
- Simulation-based — needs to run until stable (alpha decay)
- Nodes repel, edges attract
- Compound node support is tricky with d3-force — containers (switches) need a bounding force to keep their children inside. Investigate whether d3-force can handle this natively or if you need a custom force.
- Non-deterministic — consider seeding or running to full convergence for consistency

**Pre-approved dependency:** d3-force. Check if it's already available via d3; if not, `npm install d3-force` (and `@types/d3-force` if needed).

**Alternative to evaluate:** If d3-force compound node handling is too complex, consider using fCoSE via cytoscape.js instead — it handles compound nodes natively with force-directed layout. Present the tradeoff to the user before committing to one approach.

### BySwitch container rule

New `ContainerRule` variant. `applicable_perspectives()` returns `[L2Physical]`.

Groups ports by the switch (host) they belong to. Needs logic to identify which hosts are switches — hosts with IfEntry records that have SNMP data (LLDP/CDP neighbors, port info).

### Port/IfEntry as element

New `ElementEntityType` variant: `Port { if_entry_id: Uuid }` or similar.

The resolver needs metadata: icon (port status: up/down/admin-down), label (port name), display fields (speed, duplex, VLAN).

### Inspector sections for L2

| Inspecting | Primary info |
|---|---|
| Element (port/IfEntry) | Port name, admin/oper status, speed/duplex, LLDP neighbor (device + remote port), FDB MACs |
| Container (switch) | Hostname, platform (LLDP sys_desc), port count, active ports, management IP |
| Edge (PhysicalLink) | Source port ↔ target port, protocol (LLDP/CDP), speed |

### Multi-select behavior in L2

- **Bulk tagging:** Elements are ports (IfEntry records) → bulk tag targets the underlying **hosts** (switches).
- **Dependency creation:** Not available. Dependencies are irrelevant to physical wiring.

### Data available

- IfEntry records with: port names, MAC addresses, LLDP/CDP neighbor data (`lldp_chassis_id`, `lldp_port_id`, `lldp_sys_name`, `lldp_port_desc`, `lldp_mgmt_addr`, `cdp_device_id`, `cdp_port_id`), admin/oper status, speed, ifType, FDB MACs
- PhysicalLink edges created from resolved LLDP/CDP neighbors
- `DiscoveryProtocol` enum (LLDP, CDP)

---

## Batch D: Data Collection for Advanced Grouping

These are daemon-side + migration tasks. They don't depend on Batches B or C but enable richer grouping once those perspectives exist.

### D1: Docker Compose project + network name (small)

The daemon Docker scanner already has access to this data during discovery but doesn't persist it.

- **Docker stack name:** Available from container labels (`com.docker.compose.project`). This is the Compose project name — what users call a "stack" (multiple services in a single docker-compose.yml). Persist on the service or as metadata. Enables `ByStack` container rule in Infrastructure — group containers by the stack they belong to (e.g., "media-stack", "monitoring").
- **Docker network name:** Docker networks are already represented as `SubnetType::DockerBridge` subnets in L3. No separate ByVirtualNetwork rule needed — the network grouping is already handled via the existing subnet model. However, persisting the Docker network *name* (e.g., "media_default" vs just the CIDR) would improve container labels and inspector detail. This is a labeling improvement, not a new grouping rule.

**Where to look:** `backend/src/daemon/discovery/integration/docker/scanner.rs` — the scanner code that creates containers and bridge subnets. The label/network data is available in the Docker API response; it just needs to be extracted and stored.

**Data model:** Evaluate whether these should be fields on existing entities (service, subnet) or stored as metadata/tags. The simplest approach is probably a field on the service (`compose_project: Option<String>`) and a field on the subnet (`docker_network_name: Option<String>`).

### D2: VLAN identity (larger)

This is more involved — it requires new SNMP polling, a data model decision, and potentially a new entity.

- **What to poll:** SNMP VLAN MIBs — `dot1qVlanCurrentTable` (IEEE 802.1Q), `vtpVlanTable` (Cisco VTP). These return VLAN IDs, names, and port membership.
- **Data model (directional, not final):** VLAN identity associated with subnets and/or ports. Options: field on Subnet (`vlan_id: Option<u16>`), field on IfEntry (`vlan_ids: Vec<u16>`), or a separate VlanGroup entity. The coordinator should evaluate tradeoffs and present a recommendation.
- **Enables:** `ByVLAN` container rule in both L3 (group subnets by VLAN) and L2 (group ports by VLAN).

**Note:** D2 is the lowest priority of all work items here. If it's too large to fit in this batch, defer it and note the recommended data model approach for a future session.

---

## Step 1: Assess

1. Check `dev` branch state, active worktrees, test status
2. Study the existing PerspectiveBuilder implementations (L3Builder, ApplicationBuilder) — understand the pattern
3. Study the LayoutEngine interface and ElkLayoutEngine — understand what ForceLayoutEngine needs to implement
4. Study the inspector section model — understand how to add new perspective sections
5. Read the Docker scanner code to understand what data is available for D1
6. Check if d3-force is already installed or available via existing d3 dependency

**Present assessment and task breakdown to user. Wait for approval before creating worktrees.**

## Step 2: Plan Tasks

**IMPORTANT: Batch B (Infrastructure) runs FIRST, not in parallel with C.** Infrastructure is simpler (same layout engine, well-understood data model) and will surface any abstraction issues in the PerspectiveBuilder pattern, LayoutEngine interface, inspector section model, or element type system before we tackle the riskier L2 work. Only after B is merged and reviewed do we start C.

Recommended sequence:

**Round 1:**
- **Worktree 1: Infrastructure perspective** (Batch B) — InfrastructureBuilder, ByVirtualizer, Host-as-element, inspector sections. Uses elkjs, so no layout engine work.
- **Worktree 2: Docker data collection** (D1) — Stack name + network name persistence. Small, daemon-side only. Can run alongside B.

**Round 2 (after B is merged and reviewed):**
- **Worktree 3: L2 perspective** (Batch C) — L2Builder, ForceLayoutEngine, BySwitch, Port-as-element, inspector sections. Benefits from any abstraction fixes discovered during B.
- **Worktree 4: VLAN data collection** (D2) — Only if scope is manageable. Otherwise defer with a written recommendation.

**Present task breakdown with dependencies and wait for approval before creating worktrees.**

## Step 3: Execute

Create worktrees per CLAUDE.md coordinator workflow.

### Abstraction watchdog (CRITICAL)

Both the coordinator and workers must actively watch for abstraction issues. This is an explicit part of the job, not an afterthought.

**At the coordinator level:** When reviewing completed worktree work, check:
- Does the new PerspectiveBuilder implementation follow the exact same patterns as L3Builder and ApplicationBuilder? If it required workarounds, hacks, or patterns that diverge from existing builders, the abstraction has a gap. Flag it.
- Did the worker need to modify shared code (the PerspectiveBuilder trait, LayoutEngine interface, inspector section model, element type system) to make their perspective work? If so, was the modification a clean extension or a special case? Special cases signal abstraction problems.
- Are there any `if perspective == Infrastructure` or `if perspective == L2Physical` conditionals in shared code? Those are abstraction failures — the shared code should dispatch via traits/interfaces, not conditionals.

**At the worker level:** Workers must document in their TASK.md work summary:
- Any place where the existing abstractions didn't fit and they had to work around them
- Any shared code they modified and why
- Any patterns from L3Builder/ApplicationBuilder they couldn't follow and why

After Round 1 (Infrastructure) completes:
1. Review the InfrastructureBuilder for pattern consistency with L3Builder and ApplicationBuilder
2. Fix any abstraction issues discovered BEFORE starting Round 2
3. Verify inspector sections follow the section-based model
4. Verify new container rules have correct `applicable_perspectives()` scoping
5. Run tests
6. Merge to dev
7. Present to user for review — **explicitly call out any abstraction issues found and how they were resolved**

After Round 2 (L2) completes:
1. Same review checklist
2. Merge to dev
3. Present to user for final testing of all four perspectives

## Important constraints

- **No backward compatibility needed** — pre-production.
- **i18n mandatory** for all UI strings.
- **Backend metadata drives frontend** — new element types, container types, edge types all need `TypeMetadataProvider` / `EntityMetadataProvider` implementations so the frontend picks them up via generated types.
- **ForceLayoutEngine:** If compound node handling in d3-force is problematic, present the tradeoff vs fCoSE to the user before committing. Don't spend days fighting d3-force compound support if a better library exists.
- **D2 (VLAN) may be deferred** — don't let it block the batch. If it's too large, write up the recommended approach and move on.
