# Topology: Platform Extraction + Perspectives

## Your Role

You are the coordinator for making the topology system perspective-ready and then implementing perspectives. This is a three-batch effort: platform extraction, first perspective, remaining perspectives.

## Background

Read these documents first:

1. **UX Design Doc**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/planned-work/topology-visualization-redesign.md` — The full UX plan. Key sections: four perspectives, Perspective × C4 matrix, container rules vs leaf rules, primary/overlay edge classification, Layout Engine (elkjs + d3-force), Service Flows.
2. **Project Instructions**: `/Users/maya/dev/scanopy/CLAUDE.md`
3. **Architecture Audit**: `/Users/maya/.claude/plans/toasty-plotting-kahn.md` — Detailed audit of what needs fixing, with file paths, line numbers, and recommended fixes. **Read this carefully** — it's the basis for Batch 1.

## Current State

L3 topology is working with:
- Generalized node types (Container / Element) with metadata-driven frontend rendering
- GroupingConfig with container rules and leaf rules (independent dimensions)
- Edge classification (primary/overlay per perspective, backend-driven)
- elkjs compound layered layout (client-side)
- C4-1 collapse, edge bundling, hull overlays
- Clean backend/frontend separation (backend provides structure + hints, frontend owns layout)

## Architecture audit findings

The audit identified these issues blocking multi-perspective support:

| Priority | Issue | Location |
|---|---|---|
| **P0** | `build_graph()` is monolithic L3 — no PerspectiveBuilder trait | `topology/service/main.rs`, `graph_builder.rs` |
| **P1** | TopologyRequestOptions is flat, not perspective-indexed | `topology/types/base.rs`, frontend options store |
| **P2** | No LayoutEngine interface — ELK called directly from viewer | `elk-layout.ts`, `BaseTopologyViewer.svelte` |
| **P2** | Grouping rules have no `applicable_perspectives()` | `topology/types/grouping.rs` |
| **P3** | `L3_OVERLAY_EDGE_TYPES` constant is L3-hardcoded | `edge-classification.ts` |
| **P3** | Frontend classification fallback is L3-only (dead code) | `edge-classification.ts` |
| **P3** | Structure key doesn't include perspective | `BaseTopologyViewer.svelte` |

See the full audit at the path above for detailed code references and recommended fixes.

---

## Batch 1: Platform Extraction

Pure refactoring. No new features, no visual changes. L3 topology should work identically before and after.

### 1a. PerspectiveBuilder trait (P0)

Extract a trait that each perspective implements:

```rust
trait PerspectiveBuilder {
    fn create_containers(&self, ctx: &TopologyContext) -> Vec<Node>;
    fn create_elements(&self, ctx: &TopologyContext, containers: &[Node]) -> Vec<Node>;
    fn create_edges(&self, ctx: &TopologyContext) -> Vec<Edge>;
    fn classify_edge(&self, edge: &Edge) -> EdgeClassification;
    fn layout_hints(&self, containers: &mut [Node]);
}
```

Move all current L3 logic (subnet-as-container, interface-as-element, SubnetType::vertical_order hints) into `L3Builder`. `build_graph()` becomes a generic orchestrator calling the trait. See audit Section 1 for specific code to refactor.

### 1b. Perspective-indexed options (P1)

Restructure TopologyRequestOptions:

```rust
pub struct TopologyRequestOptions {
    pub perspective: TopologyPerspective,
    pub per_perspective: HashMap<TopologyPerspective, PerspectiveOptions>,
    // global options
    pub hide_ports: bool,
}

pub struct PerspectiveOptions {
    pub container_rules: Vec<GraphRule<ContainerRule>>,
    pub element_rules: Vec<GraphRule<ElementRule>>,
    pub hide_service_categories: Vec<ServiceCategory>,
    // perspective-specific display toggles
}
```

Frontend stores per-perspective options. Switching perspectives swaps the active set, preserving each perspective's customization.

### 1c. LayoutEngine interface (P2)

```typescript
interface LayoutEngine {
    compute(input: LayoutInput): Promise<LayoutResult>;
}
```

Rename `ElkLayoutInput`/`ElkLayoutResult` to `LayoutInput`/`LayoutResult`. Wrap current elkjs code in `ElkLayoutEngine`. `BaseTopologyViewer` calls `engine.compute()` without knowing which engine. Engine selected by perspective.

### 1d. Grouping rule perspective scoping (P2)

Add `applicable_perspectives()` to ContainerRule and ElementRule. Frontend filters available rules by current perspective. BySubnet only shows in L3. ByVirtualizingService only shows in L3. Future BySwitch only shows in L2.

### 1e. Small fixes (P3)

- Include `perspective` in structure key
- Remove L3 fallback in `classifyEdge()` (backend always sends classification now)
- Replace `L3_OVERLAY_EDGE_TYPES` with `getDefaultHiddenEdgeTypes(perspective)`
- Skip old-node handle preservation on perspective change

### Batch 1 acceptance criteria

- L3 topology renders identically to before
- `build_graph()` dispatches to `L3Builder` via trait
- Options are perspective-indexed (switching to another perspective and back preserves L3 settings)
- Layout goes through `LayoutEngine` interface
- Grouping rules scoped to applicable perspectives
- All tests pass

**After Batch 1: STOP. Merge to dev. Present to user. Verify L3 still works. Do not proceed until approved.**

---

## Batch 2: Application Perspective + Service Flows

The Application perspective is the best first perspective to implement because:
- All data exists (services, categories, RequestPath/HubAndSpoke groups, bindings)
- Uses the same layout engine (elkjs compound layered) — no d3-force needed yet
- Forces the Service Flow rework (Groups → Service Flows), which needs to happen regardless
- Exercises the PerspectiveBuilder trait and perspective-indexed options with a real second perspective

### 2a. ApplicationBuilder

Implement the PerspectiveBuilder trait for Application:
- **Containers:** Service categories (ByServiceCategory as implicit container rule)
- **Elements:** Individual services, labeled with name + host
- **Primary edges:** Service Flow edges (RequestPath, HubAndSpoke)
- **Overlay edges:** ServiceVirtualization (which services are containerized)
- **Layout hints:** Service categories could have a natural ordering (infrastructure services top, application services middle, end-user services bottom) — or no layer hints, letting elkjs optimize freely

### 2b. Service Flow rework

Rename "Groups" → "Service Flows" throughout UI and API:
- Update entity name, API endpoints, UI labels, i18n keys
- **Do NOT rename the backend `Group` entity/table yet if it's too invasive** — the user-facing rename is what matters. Backend can keep the name internally if needed.

Rework the creation UX:
- Current: user must specify port bindings (L3 implementation detail)
- Target: user picks services (service A → service B), system resolves to bindings internally
- Port binding selection becomes optional refinement for power users
- Service Flows are created/managed from the Application perspective (or a global management view)

### 2c. Perspective selector UI

A control for switching perspectives. Progressive disclosure — L3 is default, others are discoverable.
- Tabs, dropdown, or segmented control in the topology toolbar
- Switching triggers: swap options set, rebuild graph via new PerspectiveBuilder, re-layout
- Respect the P3 fixes from Batch 1 (structure key includes perspective, handle preservation skipped on switch)

### Batch 2 acceptance criteria

- User can switch between L3 and Application perspectives
- Application perspective shows services grouped by category with Service Flow edges
- Service Flows can be created at service level (not just port binding level)
- UI says "Service Flows" everywhere, not "Groups"
- Switching L3 → Application → L3 preserves each perspective's options
- All tests pass

**After Batch 2: STOP. Merge to dev. Present to user. Verify both perspectives work. Do not proceed until approved.**

---

## Batch 3: Infrastructure + L2 Perspectives

### 3a. InfrastructureBuilder

- **Containers:** Hypervisor hosts / Docker hosts
- **Elements:** VMs / containers (as hosts or services depending on grouping)
- **Primary relationship:** Virtualization expressed as containment (VM inside hypervisor container)
- **Container rules:** ByHypervisor (default), ByHost, future ByWorkloadGroup
- **Layout:** elkjs compound layered
- **Data:** HostVirtualization and ServiceVirtualization relationships already exist

### 3b. L2Builder + force-directed layout

- **Containers:** Switches (hosts with IfEntry/SNMP data)
- **Elements:** Ports (IfEntry records)
- **Primary edges:** PhysicalLink (LLDP/CDP)
- **Layout:** d3-force (new ForceLayoutEngine implementing the LayoutEngine interface)
- **Container rules:** BySwitch (default), future ByVLAN
- **Data:** LLDP/CDP neighbor data, IfEntry port info all exist

This batch requires:
- `ForceLayoutEngine` implementation (d3-force)
- Two new PerspectiveBuilder implementations
- New ContainerRule variants (ByHypervisor, BySwitch) with perspective scoping
- New ElementEntityType variants (Port, Host-as-element) with resolver metadata

### Batch 3 acceptance criteria

- All four perspectives render and are switchable
- L2 uses force-directed layout, others use elkjs
- Infrastructure shows VMs inside hypervisor containers
- Each perspective's grouping rules are scoped correctly
- All tests pass

---

## Step 1: Assess and Plan

Before starting Batch 1:

1. Check `dev` branch state, worktrees, test status
2. Read the architecture audit in detail — verify the code references are still accurate after the naming normalization + grouping rework
3. Break Batch 1 into parallelizable worktree tasks. Likely:
   - Backend: PerspectiveBuilder trait + L3Builder extraction + perspective-indexed options + rule scoping
   - Frontend: LayoutEngine interface + perspective-indexed option store + P3 small fixes
   - These may be parallelizable since they touch different layers

**Present task breakdown to user and wait for approval before creating worktrees.**
