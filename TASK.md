> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Beszel Agent & Zabbix Agent — Research and Implementation

## Objective
Research detection methods for Beszel Agent and Zabbix Agent, then implement service definitions with the best available pattern. These services use binary protocols without HTTP endpoints on their primary ports.

GitHub Issues: #368 (Beszel Agent), #367 (Zabbix Agent)

## Services Overview

### Beszel Agent (#368)
- **Port**: TCP 45876
- **Protocol**: SSH-based (not standard SSH — custom key exchange)
- **Purpose**: Lightweight server monitoring agent
- **Known**: Agent creates SSH server for hub to pull metrics

### Zabbix Agent (#367)
- **Port**: TCP 10050 (IANA-assigned)
- **Protocol**: Binary with "ZBXD" header
- **Purpose**: Monitoring agent for Zabbix server
- **Known**: Protocol header is `ZBXD\x01` followed by data length

## Research Tasks

### Task 1: Beszel Agent Deep Dive
Research and answer:
1. Does Beszel Agent respond to any probe on port 45876?
2. Is there an HTTP endpoint on a different port (hub uses 8090)?
3. Does the SSH handshake have identifiable characteristics?
4. Any MAC vendor association?

**Research sources:**
- [Beszel GitHub](https://github.com/henrygd/beszel)
- [Beszel Agent Installation](https://beszel.dev/guide/agent-installation)
- Source code for agent SSH implementation

### Task 2: Zabbix Agent Deep Dive
Research and answer:
1. Does Zabbix Agent respond to a simple probe with identifiable header?
2. Can we send a minimal request and get a "ZBXD" response?
3. Is there an HTTP interface on any port?
4. Does `agent.ping` or `agent.version` return useful data?

**Research sources:**
- [Zabbix Agent Protocol](https://www.zabbix.com/documentation/current/en/manual/appendix/protocols/zabbix_agent)
- [Zabbix Header Format](https://www.zabbix.com/documentation/current/en/manual/appendix/protocols/header_datalen)

## Implementation Options

Based on research, implement using the best available pattern:

### Option A: Port-Only (Fallback)
```rust
fn discovery_pattern(&self) -> Pattern<'_> {
    Pattern::Port(PortType::new_tcp(PORT))
}
```
- Confidence: Low (common port) or Medium (unique port)

### Option B: Custom Pattern with Probe
If protocol allows simple identification:
```rust
fn discovery_pattern(&self) -> Pattern<'_> {
    Pattern::Custom(
        |params| { /* check for protocol response */ },
        |params| vec![PortType::new_tcp(PORT)],
        "Service identified via protocol probe",
        "No response to protocol probe",
        MatchConfidence::High,
    )
}
```
This would require scanner modifications similar to BACnet.

### Option C: Combined Patterns
If additional signals exist:
```rust
Pattern::AllOf(vec![
    Pattern::Port(PortType::new_tcp(PORT)),
    Pattern::MacVendor("..."),  // if applicable
])
```

## Files to Create

| File | Service |
|------|---------|
| `backend/src/server/services/definitions/beszel_agent.rs` | Beszel Agent |
| `backend/src/server/services/definitions/zabbix_agent.rs` | Zabbix Agent |

**Note**: Existing `zabbix.rs` is for Zabbix Server (HTTP `/zabbix` endpoint), NOT the agent.

## Service Categories
- Both → `ServiceCategory::Monitoring`

## Acceptance Criteria
- [ ] Research documented in Work Summary
- [ ] Best detection method identified for each service
- [ ] Service definitions implemented with appropriate confidence level
- [ ] If port-only, document limitations clearly in description or comments
- [ ] `cargo test` passes
- [ ] `make format && make lint` passes

## Decision Points
If research reveals:
- **Protocol can be probed**: Implement similar to BACnet (scanner modification) — coordinate with BACnet worker or note for follow-up
- **No reliable detection**: Implement port-only with clear documentation that confidence is limited
- **HTTP endpoint exists**: Use standard Endpoint pattern

---

## Work Summary

### Research Findings

#### Beszel Agent
- **Port**: TCP 45876 (default, configurable)
- **Protocol**: SSH-based using Go's gliderlabs/ssh library
- **Architecture**: Agent creates SSH server for the hub to pull metrics; uses WebSocket as primary connection with SSH as fallback
- **Authentication**: Public key + token-based authentication
- **HTTP Endpoints**: None exposed by the agent itself
- **Detection Characteristics**: SSH banner may be identifiable but would require SSH handshake probing

Sources:
- https://beszel.dev/guide/agent-installation
- https://github.com/henrygd/beszel
- https://github.com/gliderlabs/ssh

#### Zabbix Agent
- **Port**: TCP 10050 (IANA-assigned for zabbix-agent)
- **Protocol**: Binary with "ZBXD\x01" header (5 bytes) + 8-byte little-endian data length
- **Operation**: Passive checks where server sends command (e.g., "agent.ping"), agent responds with ZBXD-wrapped data
- **Response**: For `agent.ping`, returns "1" wrapped in ZBXD protocol header
- **HTTP Endpoints**: None on agent port (Zabbix Server has web UI, not the agent)

Sources:
- https://www.zabbix.com/documentation/current/en/manual/appendix/protocols/header_datalen
- https://www.zabbix.com/documentation/2.4/en/manual/appendix/items/activepassive

### Implemented

**Files created:**
- `backend/src/server/services/definitions/beszel_agent.rs` - Beszel Agent service definition
- `backend/src/server/services/definitions/zabbix_agent.rs` - Zabbix Agent service definition

**Files modified:**
- `backend/src/server/services/definitions/mod.rs` - Added module declarations

### Detection Method Chosen

Both services use **port-only detection** (`Pattern::Port`):
- **Beszel Agent** (45876/tcp): Unique port not used by other known services → Medium confidence
- **Zabbix Agent** (10050/tcp): IANA-assigned port specifically for Zabbix agent → Medium confidence

The existing pattern matching code automatically assigns Medium confidence for unique custom ports that aren't used by other service definitions, which is appropriate for both services.

**Why not protocol-level detection:**
- Both services use binary/SSH protocols without HTTP endpoints
- Protocol probing would require scanner modifications similar to BACnet
- Port-only provides reasonable confidence given the unique/IANA-assigned nature of both ports

### Deviations

None. Implemented as Option A (Port-Only) per TASK.md since neither service has HTTP endpoints on its primary port.

### Notes for Merge

- **No scanner modifications required** - Port-only detection works within existing infrastructure
- **Higher confidence possible** with future scanner modifications:
  - Zabbix Agent: Send ZBXD-wrapped "agent.ping" and check for "ZBXD\x01" response header
  - Beszel Agent: Initiate SSH handshake and check for identifiable banner/characteristics
- **Note on existing Zabbix definition**: `zabbix.rs` is for Zabbix Server (HTTP `/zabbix` endpoint), while `zabbix_agent.rs` is for the agent (port 10050) - these are complementary
