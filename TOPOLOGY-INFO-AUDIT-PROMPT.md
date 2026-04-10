# Topology: Element Card & Inspector Information Audit

## Your Role

You are auditing the content and information hierarchy of topology element cards and the inspector panel across all implemented perspectives (L3, Application, Infrastructure). Your output is a report — you do not implement changes.

## Background

Read these documents first:

1. **UX Design Doc**: `/Users/maya/.claude/projects/-Users-maya-dev-scanopy/planned-work/topology-visualization-redesign.md` — Key sections: "Inspector Panel (C4-3 / C4-4)" for per-perspective inspector tables, each perspective's "What it shows" section, the Perspective × C4 matrix.
2. **Project Instructions**: `/Users/maya/dev/scanopy/CLAUDE.md`

## Jobs to be done per perspective

Each perspective answers a different question. The element cards and inspector must be optimized for that question — information relevant to the job should be prominent, information from other perspectives should be subordinate or absent.

### L3 Logical — "How is my network logically segmented?"

The user is looking at interfaces (a host's presence on a subnet). They care about:
- **Primary:** Which host is this? What IP does it have on this subnet?
- **Secondary:** What services run here? What ports are open?
- **Tertiary:** Tags, entity source

They do NOT primarily care about: which hypervisor runs this host (Infrastructure concern), what application group it belongs to (Application concern), or what physical switch port it's on (L2 concern).

### Application — "How do my services depend on each other?"

The user is looking at services. They care about:
- **Primary:** What is this service? (Service name only — no IP, no subnet)
- **Secondary:** What are its inbound and outbound dependencies? This is the KEY differentiator — dependencies are central information here, not supplementary.
- **Tertiary:** What host runs it, port bindings, tags

They do NOT primarily care about: subnet placement, IP addresses, physical connectivity. Host name is context, not identity. IP addresses are L3 detail and should NOT appear in element labels.

### Infrastructure — "What runs where?"

The user is looking at hosts (VMs, containers, bare metal). They care about:
- **Primary:** What is this host? What platform? (VM name, Docker container name, bare metal hostname)
- **Secondary:** What services run on it? What virtualizer manages it?
- **Tertiary:** Network interfaces, tags

They do NOT primarily care about: service dependencies, subnet topology, physical wiring.

## What to audit

### 1. Element cards (the node rendered on the canvas)

For each perspective, document:

**What's shown:**
- Title/primary label — what text, what size, what color?
- Subtitle/secondary label — what text, what size, what color?
- Icons — what icon, where positioned?
- Badges/indicators — status, counts, tags?
- Overall card size, padding, visual weight

**Evaluate against the job:**
- Does the primary label answer the perspective's core question?
- Is the information hierarchy correct? (Most important info = largest/most prominent)
- Is irrelevant information present? (e.g., IP addresses in Application view)
- Is important information missing?
- Are generic services (`is_generic`) hidden in Application view?

### 2. Container headers

For each perspective, document:
- What's in the container header (label, icon, counts)?
- When collapsed, what summary is shown? Is the element count label perspective-aware? (Should be "host interfaces" in L3, "services" in Application, "hosts" in Infrastructure)
- Is the collapsed summary useful or confusing? (Check for ambiguous count breakdowns — e.g., "26 hosts" with subcontainer counts that may or may not be included in the total)

### 3. Inspector panel — single selection

For each perspective, when the user clicks ONE element:

**What sections are shown:**
- List every section in the inspector, in order
- What data does each section display?
- What other entities are shown alongside the selected element? (e.g., "related services", "connected hosts", "dependencies")

**Evaluate against the job:**
- Does the section ordering match the perspective's information priority?
- In Application, do dependencies (inbound + outbound) appear prominently, or are they buried below host/network details?
- In L3, is the host/IP/subnet information leading?
- In Infrastructure, is the platform/virtualizer information leading?
- Are there sections from other perspectives leaking in with inappropriate prominence?

### 4. Inspector panel — multi-selection

For each perspective, when the user selects MULTIPLE elements:

**What's available:**
- Bulk tagging — what entity type is being tagged? Is it correct for the perspective? (L3 → hosts, Application → services, Infrastructure → hosts)
- Dependency creation — is it available? Is it perspective-appropriate? (Only Application and L3 with binding selection)
- Any other bulk actions?

### 5. Inspector panel — container selection

For each perspective, when the user clicks a CONTAINER:

**What's shown:**
- Container details (name, type, metadata)
- Child summary
- Edges crossing this container's boundary

### 6. Inspector panel — edge selection

For each perspective, when the user clicks an EDGE:

**What's shown:**
- Edge type, source/target
- Edge-specific details (port pair for PhysicalLink, service chain for RequestPath, etc.)
- Is the detail level appropriate for the perspective?

## Output format

For each audit area, provide:

1. **Current state** — exactly what's rendered/shown, with file paths and line numbers
2. **Assessment** — does it match the perspective's job to be done? Rate as: Correct / Needs adjustment / Wrong
3. **Specific issues** — concrete problems with information hierarchy, missing/irrelevant info, wrong emphasis
4. **Recommendation** — what should change, ordered by impact

Organize the report by perspective, not by audit area. For each perspective, walk through: element cards → container headers → inspector (single) → inspector (multi) → inspector (container) → inspector (edge).

**Present the full report to the user. Do not implement changes.**
