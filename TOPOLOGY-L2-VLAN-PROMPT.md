# Topology: L2 Physical Perspective + VLAN

## Your Role

You are the coordinator for implementing the L2 Physical perspective and VLAN data collection/grouping. This is the final perspective implementation for launch.

## Background

Read these documents first:

1. **UX Design Doc**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/planned-work/topology-visualization-redesign.md` — Key sections: Perspective 1 (L2 Physical), Edge Classification, Layout Engine (d3-force for L2), Inspector Panel (L2 sections), container rule nesting/stacking model.
2. **Project Instructions**: `/Users/maya/dev/scanopy/CLAUDE.md`
3. **Status Tracker**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/memory/project_topology_perspectives_status.md`

## Current State

Three perspectives are implemented (L3, Application, Infrastructure). The platform is solid:

- `PerspectiveBuilder` trait with L3Builder, ApplicationBuilder, InfrastructureBuilder
- `LayoutEngine` interface with `ElkLayoutEngine`
- `EdgeViewConfig` with per-perspective affects_layout / default_visibility / stroke
- Perspective-indexed options, perspective-aware inspector panel, perspective selector UI
- Container rules + element rules with `applicable_perspectives()` scoping

Study the existing builders (especially L3Builder and InfrastructureBuilder) to understand the patterns. L2 should follow the same patterns but introduces a new layout engine.

---

## Work Item 1: L2 Physical Perspective

### L2Builder

Implement `PerspectiveBuilder` for L2:

- **Containers:** Switches — hosts that have IfEntry records with SNMP/LLDP/CDP data. A switch is identified by having LLDP/CDP neighbor data or significant IfEntry records.
- **Elements:** Ports (IfEntry records). Each element shows port name, status (up/down), speed.
- **Primary edges:** PhysicalLink (LLDP/CDP discovered connections). Labels show port pair (e.g., "Gi0/1 ↔ Gi0/2").
- **Layout:** d3-force (force-directed) — NOT elkjs. L2 is a peer-to-peer graph with no implied hierarchy.

### Edge view config for L2

Per the EdgeViewConfig system already in place:

| Edge Type | affects_layout | visibility | stroke |
|---|---|---|---|
| PhysicalLink | true | Visible | Solid |
| Interface | false | Visible | Dashed |
| HostVirt, ServiceVirt, RequestPath, HubAndSpoke | Disabled | | |

### ForceLayoutEngine

Implement the `LayoutEngine` interface using d3-force (or alternative — see below):

```typescript
class ForceLayoutEngine implements LayoutEngine {
    async compute(input: LayoutInput): Promise<LayoutResult>;
}
```

Key differences from ELK:
- No layer constraints — no hierarchy
- Simulation-based — run until stable
- Nodes repel, edges attract
- Non-deterministic — consider running to full convergence for consistency

**Compound node challenge:** Switches are containers with ports inside. d3-force doesn't natively support compound nodes (children constrained within parent boundaries). Options:

1. **d3-force with custom bounding force** — add a force that constrains child nodes within their parent's bounding box. Workable but requires custom code.
2. **fCoSE (via cytoscape.js)** — compound force-directed layout that handles container/child relationships natively. Maintained by Bilkent University's visualization group. More dependency weight but solves the problem cleanly.
3. **Two-phase layout** — use d3-force for inter-switch positioning, then grid/pack child ports within each switch boundary. Simpler but less organic.

**Evaluate the tradeoffs and present a recommendation to the user before committing.** Don't spend days fighting d3-force compound support if a better library exists.

**Pre-approved dependency:** d3-force. If recommending fCoSE/cytoscape.js instead, present the case for user approval.

### BySwitch container rule

New `ContainerRule` variant. `applicable_perspectives()` returns `[L2Physical]`.

Groups ports by the switch (host) they belong to. Logic to identify switches: hosts with IfEntry records that have LLDP/CDP neighbor data.

### Port/IfEntry as element

New `ElementEntityType` variant: `Port { if_entry_id: Uuid }`.

Resolver metadata: icon based on port status (up/down/admin-down), label = port name, display fields = speed, duplex.

### Inspector sections for L2

| Inspecting | Primary info |
|---|---|
| Element (port/IfEntry) | Port name, admin/oper status, speed/duplex, LLDP neighbor (device + remote port), FDB MACs |
| Container (switch) | Hostname, platform (LLDP sys_desc), port count, active ports, management IP |
| Edge (PhysicalLink) | Source port ↔ target port, protocol (LLDP/CDP), speed |

### Multi-select behavior

- **Bulk tagging:** Elements are ports → bulk tag targets the underlying **hosts** (switches).
- **Dependency creation:** Not available. Dependencies are irrelevant to physical wiring.

### Data available

- IfEntry records with: port names, MAC addresses, LLDP/CDP neighbor data, admin/oper status, speed, ifType, FDB MACs
- PhysicalLink edges from resolved LLDP/CDP neighbors
- `DiscoveryProtocol` enum (LLDP, CDP)

---

## Work Item 2: VLAN Data Collection

### SNMP VLAN MIB polling

Add VLAN discovery to the SNMP polling pipeline:

- **Standard MIBs:** `dot1qVlanCurrentTable` (IEEE 802.1Q) — VLAN IDs, names
- **Cisco-specific:** `vtpVlanTable` (VTP) — VLAN IDs, names, status
- **Port-VLAN mapping:** `dot1qVlanCurrentEgressPorts` or `dot1qPvid` — which ports belong to which VLANs (access/trunk)

### Data model

This needs a recommendation. Options:

1. **Field on Subnet:** `vlan_id: Option<u16>` — simple, works for "this subnet is on VLAN 10." Doesn't handle trunk ports or per-port VLAN assignment.
2. **Field on IfEntry:** `vlan_ids: Vec<u16>` — captures per-port VLAN membership. Good for L2 (which ports carry which VLANs).
3. **Separate VLAN entity** — full entity with id, name, network_id. Subnets and IfEntries reference it. Most flexible, most work.
4. **Combination:** VLAN entity for the VLAN itself (ID + name), plus references from Subnet and IfEntry.

**Evaluate and recommend.** Consider: what queries will ByVLAN need to run? What data does the inspector need to show?

### ByVLAN container rule

New `ContainerRule` variant. `applicable_perspectives()` returns `[L3Logical, L2Physical]`.

In L3: groups subnets by their VLAN. In L2: groups ports by their VLAN assignment.

### Container rule nesting — design exploration

The UX design doc describes container rule stacking (ByVLAN → BySubnet creates VLAN containers with subnets inside). However, **explore alternatives to drawing more boxes.** Nested containers get visually cluttered. Consider:

- **Color-coding:** Containers colored by their VLAN. A legend/sidebar shows VLAN → color mapping. No extra visual layers.
- **Badge/label:** Each subnet container shows its VLAN ID as a badge in the header. Filtering by VLAN highlights/dims containers.
- **Grouping without nesting:** VLAN as a visual indicator (color, badge, spatial proximity) rather than a wrapping container.
- **Collapsible nesting:** VLAN containers exist but are collapsed by default — they act as section headers, expandable on demand.

**Present options with mockup descriptions to the user before implementing.** The right approach may not be traditional nesting.

---

## Abstraction watchdog (CRITICAL)

This is the fourth PerspectiveBuilder implementation. By now the pattern should be well-established. Watch for:

- Does L2Builder follow the exact same patterns as L3Builder, ApplicationBuilder, InfrastructureBuilder?
- Does ForceLayoutEngine plug into the LayoutEngine interface cleanly, or does the interface need modification?
- Do the new ContainerRule and ElementEntityType variants integrate mechanically, or require shared code changes?
- Any `if perspective == L2Physical` conditionals in shared code = abstraction failure.

Document any abstraction issues found in the TASK.md work summary.

---

## Step 1: Assess

1. Check `dev` branch state, active worktrees, test status
2. Study existing PerspectiveBuilder implementations — understand the pattern
3. Study LayoutEngine interface — understand what ForceLayoutEngine needs
4. Read the SNMP polling pipeline to understand where VLAN MIB polling fits
5. Check if d3-force is already installed; evaluate compound node options
6. Read IfEntry model to understand existing LLDP/CDP/VLAN-adjacent fields

**Present assessment and task breakdown to user. Wait for approval before creating worktrees.**

## Step 2: Plan Tasks

Recommended:

- **Worktree 1: L2 perspective** — L2Builder, ForceLayoutEngine, BySwitch, Port element, inspector sections, edge view config. This is the core work.
- **Worktree 2: VLAN data collection** — SNMP MIB polling, data model, ByVLAN rule. Daemon-side + migration. Independent of worktree 1.
- **VLAN visualization** — depends on both worktrees completing. May be a third worktree or done after merge. Present the nesting alternatives to the user before implementing.

**Present task breakdown and wait for approval before creating worktrees.**
