# Topology: Grouping Architecture Rework

## Your Role

You are the coordinator for reworking the grouping rule architecture. This is a focused refactor of existing functionality — no new features, no new perspectives.

## Background

Read these documents first:

1. **UX Design Doc**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/planned-work/topology-visualization-redesign.md` — See "Grouping Rule" section for the container rule / leaf rule distinction.
2. **Project Instructions**: `/Users/maya/dev/scanopy/CLAUDE.md` — Coding conventions, worktree workflow, coordinator responsibilities.

## The Problem

The current `GroupingRule` enum mixes two independent dimensions into a single priority-ordered list:

```rust
// Current state (backend/src/server/topology/types/grouping.rs)
pub struct GroupingConfig {
    pub primary: Vec<GroupingRule>,       // These compete in one list
    pub cross_cutting: Vec<GroupingRule>, // Currently unused
    pub filters: Vec<NodeFilter>,
}

pub enum GroupingRule {
    BySubnet,                               // Container structure
    ByServiceCategory(Vec<ServiceCategory>),// Leaf organization
    ByVirtualizingService,                  // Container structure
    ByTag { tag_ids: Vec<Uuid>, label: String }, // Leaf organization
}
```

**ByVirtualizingService** changes which containers exist (merges Docker bridge subnets under their host). **ByServiceCategory** and **ByTag** organize nodes within an existing container into sub-groups. These are different operations that should be configured independently, not prioritized against each other.

## The Target

```rust
pub struct GroupingConfig {
    pub container_rules: Vec<ContainerRule>,  // How containers relate / nest
    pub leaf_rules: Vec<LeafRule>,            // How nodes within containers are sub-grouped
    pub filters: Vec<NodeFilter>,
}
```

**Container rules** — affect macro structure (which containers exist, how they merge/nest):
- `ByVirtualizingService` — merge Docker bridge subnets under their host
- The perspective's implicit primary (BySubnet for L3) is always present
- Future: ByVLAN (nest subnets under VLAN groups)

**Leaf rules** — affect micro organization within each container:
- `ByServiceCategory(Vec<ServiceCategory>)` — sub-group infra services (replaces "left zone")
- `ByTag { tag_ids, label }` — sub-group by user-defined tags

A user configures both dimensions independently. "Merge Docker bridges by host" (container rule) + "group DNS and ReverseProxy into infra zone" (leaf rule) compose without conflict.

## What to build

### Backend

1. **Split the enum** — Create `ContainerRule` and `LeafRule` enums. Move each variant to its proper type.
2. **Update GroupingConfig** — Replace `primary: Vec<GroupingRule>` with `container_rules: Vec<ContainerRule>` + `leaf_rules: Vec<LeafRule>`.
3. **Update graph building** — Wherever `GroupingConfig` is consumed, process container rules and leaf rules in their respective phases of graph construction.
4. **Update TopologyRequestOptions** — Persist the split structure. Backward-compatible deserialization so existing stored topologies (which have the old boolean flags or old GroupingRule format) still load correctly. Serde aliases or migration-on-read.
5. **Update `GroupingConfig::from_request_options()`** — Map legacy fields to the new split structure.

### Frontend

1. **Rework the options panel** — Replace the current Docker section and Left Zone section with two "Group by" sections: one for container rules, one for leaf rules.
2. **Generic UI for both** — Each section is an ordered list of active rules with add/remove/reorder. Not hardcoded toggles. The add control offers the available rule types for that dimension (container: ByVirtualizingService, future others; leaf: ByServiceCategory, ByTag).
3. **Rule configuration** — When adding a ByServiceCategory rule, user selects which categories. When adding a ByTag rule, user selects tags and provides a label. ByVirtualizingService has no additional config.
4. **Backward compatibility in UI** — Existing topologies with legacy options should display their grouping correctly in the new UI on first load.

### What NOT to build

- No new grouping rule types (ByVLAN, BySwitch, etc.) — those come with perspectives.
- No perspective switching UI.
- No Service Flow rework.
- No changes to edge classification or layout algorithm.

## Step 1: Assess

1. Check `dev` branch state, active worktrees, test status
2. Read current GroupingConfig, GroupingRule enum, graph building code that consumes them
3. Read the frontend options panel (OptionsContent.svelte and related)
4. Read how TopologyRequestOptions is serialized/deserialized (serde attributes, stored JSONB format)
5. Identify all call sites that pattern-match on GroupingRule variants — these all need updating

**Present assessment and task breakdown to user. Wait for approval before creating worktrees.**

## Step 2: Execute

Break into worktree tasks (likely backend + frontend in parallel since the API contract between them is the GroupingConfig shape). Create worktrees per CLAUDE.md coordinator workflow.

**After completion: merge to dev, confirm existing L3 topologies render identically. The user will want to do additional UI refinements after this lands, so keep the UI clean and extensible.**
