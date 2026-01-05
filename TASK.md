# Task: ARP Scanning Redesign

> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**. Then read `DESIGN.md` for the full technical specification.

## Objective

Refactor host discovery to use broadcast ARP scanning on Linux/macOS and Windows `SendARP` API, eliminating the Npcap requirement on Windows while improving scan performance.

## Requirements

1. **Linux/macOS:** Use broadcast ARP via pnet (send all requests, collect responses)
2. **Windows default:** Use native `SendARP` API (iphlpapi) - no Npcap required
3. **Windows optional:** Support Npcap broadcast ARP via `use_npcap_arp` config flag
4. **Fallback:** Port scanning when ARP unavailable
5. **Config:** Add `use_npcap_arp` option (Windows only, default false)

## Acceptance Criteria

- [ ] `/24 subnet scan completes in ~2-3s on Linux/macOS (down from 4-5s)
- [ ] Windows works without Npcap installed (using SendARP)
- [ ] Windows with Npcap + flag enabled uses broadcast ARP
- [ ] Config option `use_npcap_arp` added (CLI flag, env var, config file)
- [ ] Graceful fallback: Npcap fails → SendARP (Windows), broadcast fails → port scan (all)
- [ ] Tests pass: `cd backend && cargo test`
- [ ] Linting passes: `make format && make lint`

## Architecture

### New Module Structure

```
backend/src/daemon/utils/
├── arp/
│   ├── mod.rs           # Public interface, platform dispatch
│   ├── broadcast.rs     # Broadcast ARP (pnet) - Linux/macOS/Windows+Npcap
│   ├── sendarp.rs       # Windows SendARP (iphlpapi)
│   └── types.rs         # ArpScanResult type
├── scanner.rs           # Updated to use new arp module
```

### Public Interface

```rust
pub struct ArpScanResult {
    pub ip: Ipv4Addr,
    pub mac: MacAddress,
}

pub async fn scan_subnet(
    interface: &NetworkInterface,
    source_ip: Ipv4Addr,
    source_mac: MacAddress,
    targets: Vec<Ipv4Addr>,
    use_npcap: bool,
) -> Result<Vec<ArpScanResult>>;

pub fn is_available(use_npcap: bool) -> bool;
```

### Platform Behavior

| Platform | Default | Optional | Fallback |
|----------|---------|----------|----------|
| Linux | Broadcast ARP | - | Port scan |
| macOS | Broadcast ARP | - | Port scan |
| Windows | SendARP | Broadcast (Npcap) | Port scan |

## Files to Modify/Create

**Create:**
- `backend/src/daemon/utils/arp/mod.rs`
- `backend/src/daemon/utils/arp/broadcast.rs`
- `backend/src/daemon/utils/arp/sendarp.rs`
- `backend/src/daemon/utils/arp/types.rs`

**Modify:**
- `backend/src/daemon/utils/mod.rs` - export arp module
- `backend/src/daemon/utils/scanner.rs` - use new arp module, remove old per-IP ARP
- `backend/src/daemon/utils/network.rs` - update discovery flow to batch by subnet
- `backend/src/daemon/config.rs` - add `use_npcap_arp` field
- `backend/src/daemon/cli.rs` - add `--use-npcap-arp` flag

**Docs (if time permits):**
- `INSTALLATION.md` - update Windows section
- `CONFIGURATION.md` - add new config option

## Implementation Notes

### Broadcast ARP Flow
1. Send all ARP requests with 200μs delay between packets
2. Wait up to 2 seconds collecting responses
3. Early exit if all targets respond
4. Return list of (IP, MAC) pairs

### SendARP Flow (Windows)
1. Call `SendARP` for each target with high concurrency (50 parallel)
2. Each call blocks until response or timeout
3. Collect successful responses

### Integration Changes

Current flow:
```
for each IP:
    arp_scan_host(ip) → wait for response/timeout
```

New flow:
```
partition IPs by subnet
for each subnet:
    results = arp::scan_subnet(all_ips_in_subnet)
```

### Constants
```rust
const ARP_TIMEOUT: Duration = Duration::from_secs(2);
const SEND_DELAY: Duration = Duration::from_micros(200);
const SENDARP_CONCURRENCY: usize = 50;
```

## Testing Notes

- Test on your available platform
- Document what needs manual testing on other platforms
- Windows CI has Npcap SDK for compilation; runtime uses SendARP by default

## Reference

Full design spec is in the original task description. Key sections:
- Broadcast implementation uses `pnet` crate
- SendARP uses `windows` crate (`Win32::NetworkManagement::IpHelper::SendARP`)
- Config follows existing pattern (`SCANOPY_` env prefix)

---

## Work Summary

### Implemented

**New ARP Module** (`backend/src/daemon/utils/arp/`)
- `types.rs`: `ArpScanResult` struct with `ip: Ipv4Addr` and `mac: MacAddress`
- `broadcast.rs`: Broadcast ARP implementation using pnet
  - Sends all ARP requests with 200μs delay
  - Collects responses for up to 2 seconds
  - Early exit when all targets respond
  - Unit tests for packet building and parsing
- `sendarp.rs`: Windows SendARP implementation (stub on non-Windows)
  - Uses high concurrency (50 parallel)
  - Leverages `windows` crate's `SendARP` from iphlpapi
- `mod.rs`: Public interface with platform dispatch
  - `scan_subnet()` function with platform-appropriate routing
  - `is_available()` to check ARP capability
  - On Windows: tries Npcap if `use_npcap=true`, falls back to SendARP
  - On Linux/macOS: uses broadcast ARP

**Config Changes** (`backend/src/daemon/shared/config.rs`)
- Added `use_npcap_arp: bool` to `AppConfig` (default: false)
- Added `--use-npcap-arp` CLI flag to `DaemonCli`
- Added `get_use_npcap_arp()` to `ConfigStore`
- Updated frontend sync test fixture

**Scanner Changes** (`backend/src/daemon/utils/scanner.rs`)
- Updated `can_arp_scan(use_npcap: bool)` to delegate to new arp module
- Removed old per-IP ARP functions: `arp_scan_host()`, `arp_scan_host_blocking()`, `parse_arp_reply()`

**Discovery Flow Changes** (`backend/src/daemon/discovery/service/network.rs`)
- Changed Phase 1a from per-IP ARP to batch subnet ARP scanning
- Groups IPs by subnet, scans each subnet as a batch
- Logs ARP method used (SendARP vs Broadcast)
- Removed `check_host_responsive_arp()` helper

### Files Changed
- **Created:**
  - `backend/src/daemon/utils/arp/mod.rs`
  - `backend/src/daemon/utils/arp/broadcast.rs`
  - `backend/src/daemon/utils/arp/sendarp.rs`
  - `backend/src/daemon/utils/arp/types.rs`
- **Modified:**
  - `backend/src/daemon/utils/mod.rs` - export arp module
  - `backend/src/daemon/utils/scanner.rs` - delegate to arp module
  - `backend/src/daemon/shared/config.rs` - add use_npcap_arp config
  - `backend/src/daemon/discovery/service/network.rs` - batch ARP scanning
  - `backend/src/tests/daemon-config-frontend-fields.json` - sync test fixture

### Testing
- All 84 unit tests pass (`cargo test`)
- Library code passes clippy (`cargo clippy --lib -- -D warnings`)
- Code formatted with `cargo fmt`

### Manual Testing Required
- **macOS/Linux**: Verify broadcast ARP completes /24 subnet in ~2-3s
- **Windows (no Npcap)**: Verify SendARP works without Npcap installed
- **Windows (with Npcap + flag)**: Verify `--use-npcap-arp` uses broadcast ARP

### Not Implemented
- Documentation updates (INSTALLATION.md, CONFIGURATION.md) - deferred per task instructions
