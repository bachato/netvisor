> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Demo Data Overhaul — 2 Networks with Complex Topologies + Virtualization

## Objective

Rewrite demo data to have only **2 networks** (instead of 4), both with complex and interesting topologies (akin to the current Headquarters topology). Crucially, add **explicit virtualization** (Docker containers and VMs) so that virtualization relationships are visible in topology visualizations.

## Context

**Current state:** `backend/src/server/organizations/demo_data.rs` (~2800 lines) generates 4 networks:
1. Headquarters (19 hosts, 6 subnets — the most interesting topology)
2. Cloud Infrastructure (6-8 hosts, 2 subnets)
3. Remote Office - Denver (5 hosts, 2 subnets)
4. Client: Riverside Medical (5-6 hosts, 2 subnets)

**Problem:** 4 networks dilute the demo. Most have simple topologies. No virtualization relationships are modeled — Proxmox hypervisors and Docker hosts exist but have no actual VMs or containers running on them.

## Requirements

### 1. Consolidate to 2 Networks

**Network 1: "Headquarters"** — Corporate on-premises + cloud hybrid network
- Merge the most interesting elements from current HQ + Cloud networks
- Should have 25-35 hosts across multiple subnets
- Rich topology: firewalls, switches, hypervisors with VMs, Docker hosts with containers, databases, monitoring stack, IoT devices, workstations
- Multiple subnet types: Management, LAN, Servers, IoT, DockerBridge, Guest, Storage
- LLDP/CDP neighbor relationships (IfEntries) for physical link topology
- Multiple groups showing service flows (web traffic, monitoring stack, backup flow, etc.)

**Network 2: "Data Center"** (or "Remote Site" / "Branch Office" — pick what creates the most interesting topology)
- Should have 15-25 hosts
- Different topology character than HQ — e.g., more focused on specific workloads
- Interesting in its own right, not just "a smaller version of HQ"
- Should also include virtualization relationships

### 2. Add Explicit Virtualization

This is the key addition. Currently `virtualization` fields are `None` on all hosts/services.

**Proxmox VMs (HostVirtualization):**
- Create VM hosts that are **virtualized by** Proxmox hypervisors
- Set the `virtualization` field on VM hosts:
  ```rust
  virtualization: Some(Virtualization {
      virtualization_type: VirtualizationType::ProxmoxVe, // or similar
      details: VirtualizationDetails {
          service_id: <proxmox_service_id>,
          // ... other fields
      }
  })
  ```
- This creates `HostVirtualization` edges in the topology between hypervisor and VM hosts
- Example: `proxmox-hv01` runs VMs like `gitlab-vm`, `nextcloud-vm`, etc.
- The VMs should have their own interfaces, services, and subnet membership

**Docker Containers (ServiceVirtualization):**
- Create containerized services that are **virtualized by** Docker daemon services
- Set the `virtualization` field on container services
- This creates `ServiceVirtualization` edges in topology
- Example: `docker-prod01` runs containers like `traefik`, `grafana`, `prometheus`, `portainer`
- Containers should have their own services/ports on the Docker bridge subnet

**Important:** Study the existing `Virtualization`, `VirtualizationType`, and `VirtualizationDetails` types in the codebase to understand the exact structure needed. Check:
- `backend/src/server/shared/types/` for virtualization type definitions
- `backend/src/server/hosts/` for how virtualization is set on hosts
- `backend/src/server/services/` for how virtualization is set on services
- `backend/src/server/topology/` for how virtualization generates edges

### 3. Maintain Demo Quality

Keep these existing elements (adjusted for 2 networks):
- **Tags** (10) — same set, redistributed across 2 networks
- **SNMP credentials** (2) — same
- **Daemons** — 2 (one per network, at least 1 with Docker socket access)
- **Discoveries** — adjusted for 2 networks (active + historical)
- **Groups** — at least 4-6 showing different edge types and flow patterns
- **IfEntries** — LLDP/CDP neighbor data for physical link topology
- **Shares** — 1 public share for the most interesting topology
- **User API Keys** — 1

### 4. Keep the Generation Pattern

Follow the existing `DemoData::generate()` pattern:
- Same method structure: `generate_tags()`, `generate_networks()`, `generate_hosts_and_services()`, etc.
- Same UUID generation pattern (pre-generated for cross-references)
- Same service binding pattern (services → interfaces)
- Same deferred neighbor update pattern for IfEntries

## Files Likely Involved

- `backend/src/server/organizations/demo_data.rs` — main rewrite (~2800 lines)
- `backend/src/server/organizations/handlers.rs` — verify `populate_demo_data` handler still works (read only, should not need changes)

## Acceptance Criteria

- [x] Exactly 2 networks in demo data
- [x] Both networks have complex, interesting topologies (30 and 20 hosts respectively)
- [x] Proxmox VMs exist with `virtualization` field set, creating HostVirtualization edges
- [x] Docker containers exist with `virtualization` field set, creating ServiceVirtualization edges
- [x] LLDP/CDP neighbor relationships create PhysicalLink edges
- [x] Groups define service flow relationships (RequestPath, HubAndSpoke, etc.)
- [x] All existing entity types represented (tags, credentials, daemons, discoveries, shares, API keys)
- [x] Demo data populates successfully without errors
- [x] `cd backend && cargo test` passes
- [x] `cargo fmt && cargo clippy` passes

## Work Summary

### What was implemented

Rewrote `backend/src/server/organizations/demo_data.rs` (~2800 lines → ~2900 lines) to consolidate 4 networks into 2 with rich virtualization.

**Networks:** Headquarters (30 hosts, 7 subnets) + Data Center (20 hosts, 6 subnets)

**Virtualization wiring:**
- 3 Proxmox hypervisors with pre-generated service IDs
- 7 VMs with `HostVirtualization::Proxmox` referencing their hypervisor's Proxmox VE service
- 2 Docker hosts with dual interfaces (eth0 on LAN, docker0 on DockerBridge)
- 8 container services with `ServiceVirtualization::Docker` referencing their Docker daemon service

**New/modified helpers:**
- `create_host` — added `virtualization` param
- `create_service_with_id` — for services needing pre-generated UUIDs
- `create_container_service` — for Docker container services with virtualization

**LLDP:** HQ 48-port switch (6 bidirectional neighbors) + DC 24-port switch (4 bidirectional neighbors)

**Groups:** 6 network-scoped groups (3 HQ, 3 DC) using `find_binding` scoped by network_id

**Other entities adjusted:** 2 daemons, 2 daemon API keys, 4 active + 3 historical discoveries, 1 share, 1 user API key

### Files changed
- `backend/src/server/organizations/demo_data.rs` — full rewrite

### Deviations
- None — implemented as planned
