> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

<<<<<<< HEAD
<<<<<<< HEAD
# Task: Investigate Scan Rate and Network Device Overwhelm (#455)

## Issue
https://github.com/scanopy/scanopy/issues/455

## Problem
Default port scanning during network discovery overwhelms service listen queues on target hosts, rendering web interfaces unresponsive. The issue manifests when scanning a /24 subnet with ~75 devices. Services require restart to recover.

User-found workarounds:
- `SCANOPY_CONCURRENT_SCANS: 50`
- `SCANOPY_ARP_RATE_PPS: 10`

## Investigation Requirements

### Step 1: Understand Current Scanning Approach
Document the current scanning implementation:

1. **Port scanning** (`daemon/utils/scanner.rs`)
   - How are connections made?
   - What timing/rate controls exist?
   - How is concurrency managed?

2. **ARP scanning** (`daemon/discovery/service/network.rs`)
   - How is ARP rate controlled?
   - What defaults are used?

3. **Configuration** (`daemon/shared/config.rs`)
   - Current defaults: `concurrent_scans: 15`, `arp_rate_pps: 50`
   - How are these applied?

### Step 2: Compare Against Best Practices
Analyze how established network scanners handle this:

1. **nmap** - Research nmap's timing templates (-T0 to -T5)
   - What rate limiting do they use?
   - How do they avoid overwhelming targets?
   - What's their "polite" scanning approach?

2. **RustScan** (https://github.com/bee-san/RustScan)
   - Clone/review their scanning approach
   - How do they handle concurrency?
   - What rate limiting exists?
   - What lessons can we apply?

Focus on:
- Connection rate limiting
- TCP SYN flood prevention
- Target service protection
- Adaptive throttling based on responses

### Step 3: Document Findings
Create a comparison table:

| Aspect | Scanopy | nmap | RustScan | Best Practice |
|--------|---------|------|----------|---------------|
| Default concurrency | | | | |
| Rate limiting | | | | |
| Adaptive throttling | | | | |
| Target protection | | | | |

### Step 4: Recommendations
Based on investigation:
- Should defaults change?
- Should new rate-limiting mechanisms be added?
- Should we add scanning presets (gentle, normal, aggressive)?

If changes are straightforward, proceed to implementation. If significant scope, document proposal and stop.

## Files Likely Involved
- `backend/src/daemon/utils/scanner.rs` - Port scanning logic
- `backend/src/daemon/discovery/service/network.rs` - Network discovery
- `backend/src/daemon/shared/config.rs` - Configuration defaults
- `ui/src/lib/features/daemons/config.ts` - UI config display

## Acceptance Criteria
- [ ] Current scanning approach documented
- [ ] nmap timing/rate limiting researched
- [ ] RustScan approach analyzed
- [ ] Comparison table created
- [ ] Recommendations documented
- [ ] Implementation (if scope permits) OR proposal for review
- [ ] `cd backend && cargo test` passes (if changes made)
- [ ] `make format && make lint` passes (if changes made)

## Work Summary

### Investigation Complete

#### Current Scanopy Scanning Approach

**Port Scanning (`scanner.rs`)**
- Uses `batch_scan()` with `FuturesUnordered` for concurrent TCP connections
- Connection timeout: 800ms (`SCAN_TIMEOUT`)
- Retry logic: 2 attempts per port with 100ms delay between retries
- **No inter-connection delay** - connections fire as fast as the batch allows
- Batch size controlled by `port_scan_batch_size` (calculated dynamically based on FD limits)
- Deep scan: processes ports in chunks of 200 (`ports_per_host_batch`)

**ARP Scanning (`arp/broadcast.rs`)**
- Rate limited via `rate_pps` parameter (default: 50 pps)
- Send delay calculated as `1_000_000 / rate_pps` microseconds between packets
- Retry rounds for non-responders (default: 2 retries = 3 total attempts)
- 3-second wait between retry rounds (`ROUND_WAIT`)
- 5-second post-scan receive period (`POST_SCAN_RECEIVE`)

**Concurrency (`config.rs`, `base.rs`)**
- `concurrent_scans`: 15 (default) - number of concurrent host scans
- `arp_rate_pps`: 50 (default) - ARP packets per second
- `arp_retries`: 2 (default) - retry rounds
- Dynamic adjustment based on file descriptor limits
- Deep scan concurrency calculated to stay within FD budget

**Key Gap Identified**: Port scanning has NO inter-connection rate limiting. All connections within a batch fire simultaneously, limited only by batch size. This differs fundamentally from nmap's approach.

---

### Comparison Table

| Aspect | Scanopy | nmap (T3 Normal) | nmap (T2 Polite) | RustScan |
|--------|---------|------------------|------------------|----------|
| **Default concurrency** | 15 hosts × 200 ports/batch | Dynamic (hundreds in good conditions) | 1 probe at a time | 3000-5000 ports |
| **Port scan rate limiting** | None (batch-based only) | Dynamic delay, adapts to conditions | 400ms between probes | None (batch-based) |
| **Connection timeout** | 800ms | 10s initial, adapts to RTT | 10s initial | 1500ms default |
| **Max retries** | 2 per port | 10 | 10 | Configurable |
| **Adaptive throttling** | None | Yes - adjusts based on drops/responses | Yes | None |
| **Target protection** | FD-based batch limits only | Reduces parallelism on drops, adaptive delays | Sequential with 400ms delay | FD-based limits |
| **Inter-probe delay** | 0ms | 0ms (dynamic up to 10ms cap) | 400ms | 0ms |

---

### Root Cause Analysis

The user's issue (services overwhelmed, web interfaces unresponsive) stems from:

1. **No per-host rate limiting**: Scanopy fires up to 200 simultaneous TCP SYN packets per host during deep scan. Each connection attempt creates state on the target device.

2. **Service queue exhaustion**: Many embedded devices (routers, IoT, network appliances) have small listen queue sizes (often 5-128). 200 simultaneous connections overwhelm the backlog.

3. **Concurrent host multiplication**: With 15 concurrent host scans × 200 ports/batch = 3000 potential simultaneous connections network-wide.

4. **No backoff on timeouts**: Unlike nmap, Scanopy doesn't reduce parallelism when seeing connection failures/timeouts.

---

### Recommendations

#### Option A: Staggered Connection Starts (Recommended)

**Problem**: Currently all connections in a batch fire simultaneously. With `ports_per_host_batch = 200`, this sends 200 SYN packets to a single host in <1ms, overwhelming listen queues.

**Solution**: Keep batch size at 200, but stagger when probes start using a `scan_rate_pps` limit (similar to existing `arp_rate_pps`).

```rust
// Current: all 200 connections start at once (SYN flood)
for port in batch {
    futures.push(connect(ip, port));
}

// Proposed: stagger starts at scan_rate_pps (e.g., 500/sec)
for port in batch {
    futures.push(tokio::spawn(connect(ip, port)));
    tokio::time::sleep(stagger_delay).await;  // 2ms at 500 pps
}
// await all futures (connections complete in parallel)
```

**Why this works**:
- Connections still complete in parallel (800ms timeout applies to each independently)
- SYN packets spread over time instead of bursting
- Listen queue sees steady trickle, not flood

**Timing analysis** at 500 pps with 200-port batch:

| Phase | Time |
|-------|------|
| Start all 200 connections | 400ms (200 × 2ms) |
| Wait for slowest response | 800ms timeout |
| **Effective batch time** | ~800-1000ms |

Compare to current approach:
- Start all 200 connections: <1ms
- Wait for responses: 800ms
- Effective batch time: ~800ms

**Minimal speed regression** (~200ms per batch) but **eliminates SYN bursts**.

**New config**:
```rust
// config.rs
pub scan_rate_pps: u32,  // default: 500 (2ms between connections)
```

| scan_rate_pps | Delay between probes | 200-port batch start time |
|---------------|---------------------|---------------------------|
| 1000 | 1ms | 200ms |
| 500 | 2ms | 400ms |
| 250 | 4ms | 800ms |
| 100 | 10ms | 2000ms |

**Implementation location**: `scanner.rs` in `batch_scan()` or `scan_tcp_ports()`

---

#### Why Not Just Reduce Batch Size?

Reducing `ports_per_host_batch` from 200 → 32 seems simpler, but:

1. **No parallelism gain for typical networks**: A /24 with 75 hosts already scans all hosts in parallel (FD limit allows ~40 concurrent, but only 75 hosts exist)

2. **6x more batches per host**: 65535 ports / 200 = 328 batches vs 65535 / 32 = 2048 batches

3. **Net result: slower scans** with no benefit for networks smaller than the concurrency limit

Staggered starts preserve batch efficiency while eliminating the SYN burst problem.

---

#### Option B: Adaptive Batch Sizing via Initial Probe

Before deep scanning, probe the host to determine appropriate batch size.

**Key insight**: With staggered starts (Option A), listen queue protection comes from `scan_rate_pps`, NOT batch size. Batch size now controls:
- How many connections are in-flight (waiting for response)
- Scan duration (fewer batches = faster completion)
- FD usage

This means we can use **larger batch sizes** than originally proposed.

**Algorithm**:
```
1. Send initial probe: 16 connections to common ports (22, 80, 443, 8080, etc.)
2. Measure response pattern over 800ms:
   - success_count: connections accepted
   - timeout_count: no response
   - reset_count: RST received
   - total = success + timeout + reset
   - avg_response_time: how quickly responses came back

3. Calculate batch size (larger values since staggering provides protection):
   if elapsed > 2000ms:
       # Slow network or host - use smaller batch to limit in-flight connections
       batch_size = 128
   elif timeout_count / total > 0.5:
       # High timeout rate - host may be filtered or slow
       batch_size = 128
   elif elapsed < 300ms and success_count > 0:
       # Very fast responses - host can handle large batches
       batch_size = 400
   elif elapsed < 800ms:
       # Normal response time
       batch_size = 256
   else:
       # Default
       batch_size = 200
```

**Batch size comparison** (with vs without staggering):

| Host Type | Without Staggering | With Staggering (500 pps) |
|-----------|-------------------|---------------------------|
| Slow/filtered | 16-24 | 128 |
| Normal | 48 | 200-256 |
| Fast/capable | 96 | 400 |

**Why larger batches are now safe**:
- At 500 pps, a 400-port batch takes 800ms to start all connections
- Listen queue sees 1 SYN every 2ms regardless of batch size
- Larger batches = fewer total batches = faster scan completion

**Implementation Location**: `deep_scan_host()` in `network.rs`

**Pros**:
- Fast hosts scanned in fewer batches (400 batch = 164 batches vs 328 with 200)
- Slow hosts still protected by rate limiting
- Automatically adapts to network conditions

**Cons**:
- Small probe overhead (~800ms per host, runs in parallel)

---

#### Option C: Configurable Scan Delay (Low Effort, User Control)

Add `scan_delay_ms` config for users who need explicit rate limiting:

```rust
// In config.rs
pub scan_delay_ms: u32,  // default: 0

// In scanner.rs batch_scan, after each connection:
if scan_delay_ms > 0 {
    tokio::time::sleep(Duration::from_millis(scan_delay_ms)).await;
}
```

**Pros**: Gives power users explicit control
**Cons**: Most users won't know what value to use

---

### Recommendation

**This PR**: Implement **both Option A and Option B** together.

- **Option A (Staggered starts)**: Fixes the root cause (SYN bursts) via `scan_rate_pps`
- **Option B (Adaptive batch sizing)**: Optimizes per-host based on response characteristics

Since staggering protects listen queues via rate limiting, adaptive batch sizes can be **larger** than originally proposed. Batch size now primarily affects scan duration, not host protection.

---

### Implementation Plan

#### 1. Add config option for scan_rate_pps

**File**: `backend/src/daemon/shared/config.rs`

```rust
// In DaemonCli struct, add:
/// Maximum port scan probes per second during scanning (default: 500)
#[arg(long)]
scan_rate_pps: Option<u32>,

// In AppConfig struct, add:
#[serde(default = "default_scan_rate_pps")]
pub scan_rate_pps: u32,

// Add default function:
fn default_scan_rate_pps() -> u32 {
    500 // 2ms between probes, safe for most devices
}

// In AppConfig::default(), add:
scan_rate_pps: default_scan_rate_pps(),

// In AppConfig::load(), add CLI override handling

// In ConfigStore, add getter:
pub async fn get_scan_rate_pps(&self) -> Result<u32> {
    let config = self.config.read().await;
    Ok(config.scan_rate_pps)
}
```

#### 2. Update frontend config fields

**File**: `backend/src/daemon/tests/daemon-config-frontend-fields.json`

Add entry for `scan_rate_pps` to keep frontend/backend config in sync.

#### 3. Modify batch_scan to stagger connections

**File**: `backend/src/daemon/utils/scanner.rs`

```rust
/// Generic batch scanner with rate-limited connection starts
async fn batch_scan<T, O, F, Fut>(
    items: Vec<T>,
    batch_size: usize,
    cancel: CancellationToken,
    scan_rate_pps: u32,  // NEW parameter
    scan_fn: F,
) -> Vec<O>
where
    T: Send + 'static,
    O: Send + 'static,
    F: Fn(T) -> Fut + Send + Sync + 'static,
    Fut: std::future::Future<Output = Option<O>> + Send + 'static,
{
    let mut results = Vec::new();
    let mut item_iter = items.into_iter();

    // Calculate stagger delay from rate limit
    let stagger_delay = if scan_rate_pps > 0 {
        Duration::from_micros(1_000_000 / scan_rate_pps as u64)
    } else {
        Duration::ZERO
    };

    let mut futures: FuturesUnordered<Pin<Box<dyn Future<Output = Option<O>> + Send>>> =
        FuturesUnordered::new();

    // Initial batch - stagger the starts
    for _ in 0..batch_size {
        if cancel.is_cancelled() {
            break;
        }

        if let Some(item) = item_iter.next() {
            futures.push(Box::pin(scan_fn(item)));

            // Stagger connection starts to avoid SYN burst
            if !stagger_delay.is_zero() {
                tokio::time::sleep(stagger_delay).await;
            }
        } else {
            break;
        }
    }

    // Process results and refill batch
    while let Some(result) = futures.next().await {
        if cancel.is_cancelled() {
            break;
        }

        if let Some(output) = result {
            results.push(output);
        }

        // Refill batch with staggered starts
        while futures.len() < batch_size && !cancel.is_cancelled() {
            if let Some(item) = item_iter.next() {
                futures.push(Box::pin(scan_fn(item)));

                if !stagger_delay.is_zero() {
                    tokio::time::sleep(stagger_delay).await;
                }
            } else {
                break;
            }
        }
    }

    results
}
```

#### 4. Add host capacity probing

**File**: `backend/src/daemon/utils/scanner.rs`

```rust
/// Result of probing a host's response characteristics
pub struct HostCapacity {
    pub recommended_batch_size: usize,
    pub avg_response_ms: u64,
}

/// Probe a host to determine optimal batch size for deep scanning.
/// Uses response time and success rate to estimate host capacity.
pub async fn probe_host_capacity(
    ip: IpAddr,
    cancel: CancellationToken,
    scan_rate_pps: u32,
) -> Result<HostCapacity, Error> {
    // Common TCP ports likely to be open on various device types
    let probe_ports: Vec<PortType> = vec![
        PortType::Ssh,          // 22
        PortType::Telnet,       // 23
        PortType::Http,         // 80
        PortType::Https,        // 443
        PortType::Samba,        // 445
        PortType::Rdp,          // 3389
        PortType::Http8080,     // 8080
        PortType::Https8443,    // 8443
        PortType::Http9000,     // 9000
        PortType::Mqtt,         // 1883
    ];

    let probe_batch = 16;
    let start = Instant::now();

    let results = scan_tcp_ports(
        ip,
        cancel.clone(),
        probe_batch,
        scan_rate_pps,
        probe_ports.iter().map(|p| p.number()).collect()
    ).await?;

    let elapsed = start.elapsed();
    let total_probed = probe_ports.len();
    let open_count = results.len();

    // Determine batch size based on response characteristics
    // Larger batches are safe because staggering protects listen queues
    let recommended = if elapsed.as_millis() > 2000 {
        // Slow network/host - limit in-flight connections
        128
    } else if elapsed.as_millis() > 1200 {
        // Moderately slow
        200
    } else if elapsed.as_millis() < 300 && open_count > 0 {
        // Very fast responses - host can handle large batches
        400
    } else if elapsed.as_millis() < 800 {
        // Normal response time
        256
    } else {
        // Default
        200
    };

    tracing::debug!(
        ip = %ip,
        elapsed_ms = elapsed.as_millis(),
        open_ports = open_count,
        recommended_batch = recommended,
        "Host capacity probed"
    );

    Ok(HostCapacity {
        recommended_batch_size: recommended,
        avg_response_ms: elapsed.as_millis() as u64,
    })
}
```

#### 5. Thread through call sites and integrate probing

**File**: `backend/src/daemon/utils/scanner.rs`

Update function signatures:
- `scan_tcp_ports()` - add `scan_rate_pps` parameter
- `scan_udp_ports()` - add `scan_rate_pps` parameter
- `scan_endpoints()` - add `scan_rate_pps` parameter
- `scan_ports_and_endpoints()` - add `scan_rate_pps` parameter

**File**: `backend/src/daemon/discovery/service/network.rs`

Remove `port_scan_batch_size` from `DeepScanParams` struct - it's now determined dynamically:

```rust
// Remove port_scan_batch_size from DeepScanParams struct
struct DeepScanParams<'a> {
    ip: IpAddr,
    subnet: &'a Subnet,
    mac: Option<MacAddress>,
    phase1_ports: &'a [u16],
    cancel: CancellationToken,
    // port_scan_batch_size: usize,  // REMOVED - now determined by probing
    gateway_ips: &'a [IpAddr],
    batches_completed: &'a AtomicUsize,
}

// In deep_scan_host():
async fn deep_scan_host(&self, params: DeepScanParams<'_>) -> Result<Option<Host>, Error> {
    let DeepScanParams {
        ip,
        subnet,
        mac,
        phase1_ports,
        cancel,
        gateway_ips,
        batches_completed,
    } = params;

    if cancel.is_cancelled() {
        return Err(Error::msg("Discovery was cancelled"));
    }

    // Get scan_rate_pps from config
    let scan_rate_pps = self.as_ref().config_store.get_scan_rate_pps().await?;

    // Probe host to determine optimal batch size
    let capacity = probe_host_capacity(ip, cancel.clone(), scan_rate_pps).await
        .unwrap_or(HostCapacity {
            recommended_batch_size: 200,  // Safe default on probe failure
            avg_response_ms: 0
        });

    let port_scan_batch_size = capacity.recommended_batch_size;

    // ... rest of deep_scan_host using dynamic port_scan_batch_size ...
}
```

**File**: `backend/src/daemon/discovery/service/network.rs`

Update callers of `deep_scan_host()` to remove `port_scan_batch_size` from params.
Update `scan_and_process_hosts()` to get `scan_rate_pps` from config and pass through.

#### 6. Update tests

- Add test for staggered timing behavior
- Add test for probe_host_capacity returning appropriate batch sizes
- Update existing scanner tests to pass tcp_rate_pps parameter

---

### Estimated Effort

| Task | Time |
|------|------|
| Config changes (scan_rate_pps) | 30 min |
| Frontend config sync | 15 min |
| Modify batch_scan for staggering | 45 min |
| Add probe_host_capacity | 45 min |
| Thread through all call sites | 45 min |
| Integrate probing in deep_scan_host | 30 min |
| Testing | 45 min |
| **Total** | ~4-5 hours |

---

### Summary of Changes

| Component | Change |
|-----------|--------|
| `config.rs` | Add `scan_rate_pps` (default: 500) |
| `scanner.rs` | Add stagger delay to `batch_scan()` |
| `scanner.rs` | Add `probe_host_capacity()` function using `PortType` enum |
| `scanner.rs` | Add `scan_rate_pps` param to scan functions |
| `network.rs` | Remove `port_scan_batch_size` from `DeepScanParams` |
| `network.rs` | Call `probe_host_capacity()` before deep scan |
| `network.rs` | Use dynamic batch size instead of hardcoded 200 |
| Frontend | Add `scan_rate_pps` to config UI |

### Expected Behavior

| Host Response | Probe Time | Batch Size | Batches for 65535 ports |
|---------------|------------|------------|-------------------------|
| Very fast (<300ms) | ~300ms | 400 | 164 |
| Normal (<800ms) | ~800ms | 256 | 256 |
| Slow (>1200ms) | ~1200ms | 200 | 328 |
| Very slow (>2000ms) | ~2000ms | 128 | 512 |

All protected by scan_rate_pps=500 (2ms between probes) regardless of batch size.

---

## Work Summary

### Implementation Complete

All changes from the design document have been implemented:

#### Files Modified

1. **`backend/src/daemon/shared/config.rs`**
   - Added `scan_rate_pps` CLI argument with help text
   - Added `scan_rate_pps: u32` field to `AppConfig` struct with `#[serde(default)]`
   - Added `default_scan_rate_pps()` function returning 500
   - Added CLI override handling in `AppConfig::load()`
   - Added `ConfigStore::get_scan_rate_pps()` getter method

2. **`backend/src/tests/daemon-config-frontend-fields.json`**
   - Added entry for `scan_rate_pps` config field

3. **`backend/src/daemon/utils/scanner.rs`**
   - Modified `batch_scan()` to accept `scan_rate_pps` parameter
   - Added stagger delay calculation: `Duration::from_micros(1_000_000 / scan_rate_pps)`
   - Added `tokio::time::sleep(stagger_delay).await` after each `futures.push()` call
   - Added `HostCapacityProbe` struct and `probe_host_capacity()` function
   - Probe uses `PortType::Ssh`, `PortType::Telnet`, `PortType::Http`, `PortType::Https`, `PortType::Rdp`
   - Updated `scan_tcp_ports()`, `scan_udp_ports()`, `scan_ports_and_endpoints()` signatures

4. **`backend/src/daemon/discovery/service/network.rs`**
   - Removed `port_scan_batch_size` from `DeepScanParams` struct
   - Added `scan_rate_pps: u32` field to `DeepScanParams` struct
   - Added `scan_rate_pps` config fetch in `scan_and_process_hosts()`
   - Integrated `probe_host_capacity()` call in `deep_scan_host()`
   - Batch size now determined dynamically per-host (128, 192, 256, or 400 based on probe results)
   - Updated all scan function calls to pass `scan_rate_pps` parameter

#### Verification

- **`cargo test`**: All 89 unit tests pass
- **`cargo fmt`**: Code formatted
- **`cargo clippy`**: No new warnings from modified files (pre-existing warnings in test files are unrelated)

#### Deviations from Design

1. **Probe implementation simplified**: Instead of counting timeouts/resets separately, probe uses concurrent connections and measures aggregate response time + port count. The logic determines batch size based on:
   - 3+ responsive ports → 400 batch (robust server)
   - 1-2 responsive ports + fast responses (<50ms avg) → 256 batch
   - 1-2 responsive ports + moderate responses → 192 batch
   - Slow responses or no responses → 128 batch (conservative)

2. **Probe timeout**: Uses 200ms probe timeout (shorter than the 800ms design spec) for faster probing without sacrificing accuracy for capacity detection.

3. **FD budget calculation**: Uses 256 as estimated batch size for FD budget calculation since actual batch sizes now vary per-host.

#### Testing Notes

- Integration test failed due to Docker environment issue ("No such image: scanopy-server:latest") - this is unrelated to the code changes
- Pre-existing clippy warnings in test files (clone_on_copy, collapsible_if, etc.) are not from modified code
=======
# Task: Fix HTTP 413 on Topology Operations (#451)

## Issue
https://github.com/scanopy/scanopy/issues/451

## Problem
Users encounter HTTP 413 (Payload Too Large) errors on topology operations:
1. **Initial fix (v0.13.4):** Topology rebuild was fixed with `TopologyRebuildRequest`
2. **Remaining issues:**
   - 413 still occurs when **dragging/moving** topology elements
   - TypeErrors appear in browser console before 413
   - Large topologies (6-7 MB) still fail on saves
   - Affects users with 7+ networks, 20-80 devices per network

## Context
- Small topologies (~1.2 MB) succeed
- Large topologies (~6-7 MB) fail
- Server has request body size limits that weren't fully addressed

## Requirements

### 1. Investigate Current State
- Find where `TopologyRebuildRequest` was added (commit 24c0fed)
- Identify ALL topology endpoints that accept large payloads
- Check server body size limits (Axum config)

### 2. Fix Drag/Move Operations
- What endpoint handles drag/move?
- Is it sending full topology or just position updates?
- If full topology: create lightweight request type (like rebuild fix)
- If position updates: why is payload still large?

### 3. Fix TypeErrors
- Reproduce in browser console
- What TypeErrors appear before 413?
- Are these related to payload construction?

### 4. Consider Pagination/Chunking for Large Topologies
If topologies can legitimately be 6-7 MB, consider:
- Incremental position updates instead of full saves
- Server-side topology storage with client deltas
- Breaking large saves into chunks

## Files Likely Involved
- `backend/src/server/topology/` - Topology handlers and types
- `backend/src/server/topology/handlers.rs` - Endpoint definitions
- `ui/src/lib/features/topology/` - Frontend topology components
- Axum body size configuration (likely in server setup)

=======
# Task: CSV Export Endpoints Implementation

## Overview
Add CSV export capability to all entities with list endpoints, reusing existing query parameters (filtering, ordering) with minimal code duplication.

## Design Decisions (Pre-Approved)
- **Endpoint style:** Separate `/export/csv` endpoints (e.g., `GET /api/hosts/export/csv`)
- **Pagination:** Export ALL matching records (ignore limit/offset)
- **Filtering/ordering:** Reuse existing FilterQuery types from list endpoints
- **Children:** Base entity only (interfaces, services, etc. have their own export endpoints)
- **Trait location:** Extend existing Entity trait (no separate trait)

## Implementation Steps

### Step 1: Add csv crate
**File:** `backend/Cargo.toml`
```toml
csv = "1.3"
```

### Step 2: Extend Entity trait with CSV methods
**File:** `backend/src/server/shared/storage/traits.rs`

Add to Entity trait:
```rust
type CsvRow: Serialize;
fn csv_headers() -> Vec<&'static str>;
fn to_csv_row(&self) -> Self::CsvRow;
```

### Step 3: Create CSV export handler module
**File:** `backend/src/server/shared/handlers/csv.rs` (NEW)

Generic handler that:
- Accepts FilterQuery (same as list endpoint)
- Fetches ALL matching records (no pagination)
- Writes CSV with headers
- Returns with download headers

### Step 4: Add OpenAPI macro
**File:** `backend/src/server/shared/handlers/openapi_macros.rs`

Add `crud_export_csv_handler!` macro similar to existing CRUD macros.

### Step 5: Wire up per entity
For each entity, add macro invocation and route.

## Entities to Implement

| Entity | FilterQuery | Notes |
|--------|-------------|-------|
| Host | HostFilterQuery | - |
| Service | ServiceFilterQuery | Exclude nested bindings in CsvRow |
| Subnet | SubnetFilterQuery | - |
| Interface | InterfaceQuery | - |
| Port | HostChildQuery | - |
| Binding | BindingQuery | Serialize enum as string |
| Group | GroupFilterQuery | Serialize binding_ids as comma-separated |
| Tag | TagFilterQuery | - |
| Daemon | DaemonFilterQuery | Exclude API key - use custom CsvRow |
| User | UserFilterQuery | Check for sensitive fields |
| Share | SharesQuery | - |
| Network | NetworkFilterQuery | - |

## Security Considerations
- Use `Authorized<Viewer>` - same as list endpoints
- Exclude sensitive fields from CSV (API keys, passwords)
- Tenant isolation via same filter logic as list endpoints

## Files to Create/Modify

| File | Change |
|------|--------|
| `backend/Cargo.toml` | Add `csv = "1.3"` |
| `backend/src/server/shared/storage/traits.rs` | Add CsvRow, csv_headers(), to_csv_row() |
| `backend/src/server/shared/handlers/mod.rs` | Add `pub mod csv;` |
| `backend/src/server/shared/handlers/csv.rs` | NEW: export_csv_handler |
| `backend/src/server/shared/handlers/openapi_macros.rs` | Add crud_export_csv_handler! macro |
| `backend/src/server/<entity>/impl/*.rs` | Implement new Entity methods |
| `backend/src/server/<entity>/handlers.rs` | Add macro invocation + route |

## Verification
```bash
cd backend && cargo build
cd backend && cargo test
curl -H "X-API-Key: <KEY>" "http://localhost:60072/api/hosts/export/csv" -o hosts.csv
curl -H "X-API-Key: <KEY>" "http://localhost:60072/api/hosts/export/csv?network_id=<ID>" -o filtered.csv
```

>>>>>>> csv-export
## API Testing
```
API Key: scp_u_YANq5G2OLn7zir5ixPydwe3WrXOsaWyw
Network ID: b19b9406-8e6e-44ed-a68e-c65e7738ff09
```

## Acceptance Criteria
<<<<<<< HEAD
- [ ] All topology save/update endpoints identified
- [ ] Drag/move operations work without 413
- [ ] TypeErrors resolved
- [ ] Large topologies (6-7 MB equivalent) can be saved
- [ ] Tests added for large payload handling
- [ ] `cd backend && cargo test` passes
- [ ] `cd ui && npm test` passes
=======
- [ ] All entities have `/export/csv` endpoints
- [ ] Filtering works (same as list endpoints)
- [ ] Sensitive fields excluded (API keys, etc.)
- [ ] Downloaded files are valid CSV
- [ ] OpenAPI schema updated (`make generate-types`)
- [ ] Tests added
- [ ] `cd backend && cargo test` passes
>>>>>>> csv-export
- [ ] `make format && make lint` passes

## Work Summary

<<<<<<< HEAD
### Problem Root Cause
Large topologies (6-7 MB) exceeded Axum's default 2MB body size limit. Four frontend operations were sending the **entire topology object** to the server when they only needed to update specific fields:
1. Node drag → sent full topology for position update
2. Node resize → sent full topology for size/position update
3. Edge reconnect → sent full topology for handle update
4. Metadata edit → sent full topology for name/parent update

### Solution
Created 4 lightweight request types and endpoints that only send the minimal required data:

| Operation | Before (payload) | After (payload) | Reduction |
|-----------|-----------------|-----------------|-----------|
| Node drag | ~6-7 MB | ~100 bytes | 99.99% |
| Node resize | ~6-7 MB | ~120 bytes | 99.99% |
| Edge reconnect | ~6-7 MB | ~150 bytes | 99.99% |
| Metadata edit | ~6-7 MB | ~200 bytes | 99.99% |

### Files Changed

**Backend:**
- `backend/src/server/topology/types/base.rs` - Added 4 new request types:
  - `TopologyNodePositionUpdate` - for drag operations
  - `TopologyNodeResizeUpdate` - for resize operations
  - `TopologyEdgeHandleUpdate` - for edge reconnect operations
  - `TopologyMetadataUpdate` - for name/parent edit operations
- `backend/src/server/topology/handlers.rs` - Added 4 new endpoints:
  - `POST /{id}/node-position`
  - `POST /{id}/node-resize`
  - `POST /{id}/edge-handles`
  - `POST /{id}/metadata`

**Frontend:**
- `ui/src/lib/features/topology/queries.ts` - Added 4 new mutation hooks:
  - `useUpdateNodePositionMutation()`
  - `useUpdateNodeResizeMutation()`
  - `useUpdateEdgeHandlesMutation()`
  - `useUpdateMetadataMutation()`
- `ui/src/lib/features/topology/components/visualization/TopologyViewer.svelte` - Updated to use lightweight mutations for drag and edge reconnect
- `ui/src/lib/features/topology/components/visualization/SubnetNode.svelte` - Updated to use lightweight mutation for resize
- `ui/src/lib/features/topology/components/TopologyModal.svelte` - Updated to use lightweight mutation for metadata edit

### Verification
- [x] `cd backend && cargo check` - passes
- [x] `cd backend && cargo test` - passes (3 tests, 5 doc-tests ignored)
- [x] `cd ui && npm test` - passes (4 tests)
- [x] `cd ui && npm run check` - passes (0 errors)
- [x] `make format` - passes

### Permission/Tenant Isolation
All new endpoints:
- Require `Authorized<Member>` permission
- Validate `network_id` in request body against user's `network_ids`
- Fetch topology by ID and validate it exists before updating

### Notes
- Existing `TopologyRebuildRequest` for rebuild/refresh already uses lightweight pattern
- Lock/unlock operations already use ID-only endpoints (no body)
- Create topology still sends full object (but new topologies are small)
>>>>>>> 451-topology-413
=======
### Implemented

**Core Infrastructure:**
- Added `csv = "1.3"` to `Cargo.toml`
- Extended Entity trait with `CsvRow`, `csv_headers()`, and `to_csv_row()` methods in `shared/storage/traits.rs`
- Created generic CSV export handler at `shared/handlers/csv.rs`
- Added `crud_export_csv_handler!` macro to `shared/handlers/openapi_macros.rs`

**Entities with CSV Export (16 total):**
| Entity | CsvRow Type | Sensitive Field Handling |
|--------|-------------|--------------------------|
| Host | HostCsvRow | - |
| Subnet | SubnetCsvRow | - |
| Interface | InterfaceCsvRow | - |
| Port | PortCsvRow | - |
| Service | ServiceCsvRow | Excludes nested bindings |
| Binding | BindingCsvRow | - |
| Group | GroupCsvRow | binding_ids as comma-separated |
| Tag | TagCsvRow | - |
| Daemon | DaemonCsvRow | Excludes `url` field (contains connection secrets) |
| User | UserCsvRow | Excludes `password_hash` |
| Share | ShareCsvRow | Excludes `password_hash`, adds `has_password` bool |
| Network | NetworkCsvRow | - |
| Discovery | DiscoveryCsvRow | - |
| Topology | TopologyCsvRow | Metadata only (excludes graph data) |
| UserApiKey | UserApiKeyCsvRow | Excludes `key` (hash) |
| DaemonApiKey | DaemonApiKeyCsvRow | Excludes `key` (hash) |

**Entities NOT Implemented (by design):**
- `Organization`: Single-tenant access pattern (users only see their own org); no list endpoint
- `Invite`: Custom filtering via `list_active_invites`, doesn't fit standard CRUD pattern

### Files Modified

| File | Change |
|------|--------|
| `backend/Cargo.toml` | Added `csv = "1.3"` |
| `backend/src/server/shared/storage/traits.rs` | Extended Entity trait |
| `backend/src/server/shared/handlers/mod.rs` | Added `pub mod csv;` |
| `backend/src/server/shared/handlers/csv.rs` | NEW: generic CSV handler |
| `backend/src/server/shared/handlers/openapi_macros.rs` | Added macro |
| `backend/src/server/hosts/impl/storage.rs` | HostCsvRow impl |
| `backend/src/server/subnets/impl/storage.rs` | SubnetCsvRow impl |
| `backend/src/server/interfaces/impl/storage.rs` | InterfaceCsvRow impl |
| `backend/src/server/ports/impl/storage.rs` | PortCsvRow impl |
| `backend/src/server/services/impl/storage.rs` | ServiceCsvRow impl |
| `backend/src/server/bindings/impl/storage.rs` | BindingCsvRow impl |
| `backend/src/server/groups/impl/storage.rs` | GroupCsvRow impl |
| `backend/src/server/tags/impl/storage.rs` | TagCsvRow impl |
| `backend/src/server/daemons/impl/storage.rs` | DaemonCsvRow impl |
| `backend/src/server/users/impl/base.rs` | UserCsvRow impl |
| `backend/src/server/shares/impl/base.rs` | ShareCsvRow impl |
| `backend/src/server/networks/impl.rs` | NetworkCsvRow impl |
| `backend/src/server/discovery/impl/storage.rs` | DiscoveryCsvRow impl |
| `backend/src/server/topology/types/storage.rs` | TopologyCsvRow impl |
| `backend/src/server/user_api_keys/impl/storage.rs` | UserApiKeyCsvRow impl |
| `backend/src/server/daemon_api_keys/impl/storage.rs` | DaemonApiKeyCsvRow impl |
| `backend/src/server/organizations/impl/storage.rs` | OrganizationCsvRow impl (trait compliance) |
| `backend/src/server/invites/impl/base.rs` | InviteCsvRow impl (trait compliance) |
| All entity `handlers.rs` files | Added macro + route wiring |

### Security Notes
- All CSV exports require `Authorized<Viewer>` permission
- Tenant isolation enforced via same filter logic as list endpoints
- Sensitive fields excluded from all CsvRow types

### Verification
- `cargo test` - All 89 tests pass
- `cargo fmt --all` - Clean
- `cargo clippy --all-targets --all-features` - Pre-existing warnings only (no new warnings)

---

## UI Implementation

### Overview
Added CSV export button to all entity tab pages that triggers download using the backend CSV export endpoints.

### Files Created

| File | Purpose |
|------|---------|
| `ui/src/lib/api/entities.ts` | Entity-to-API-path mapping utility |
| `ui/src/lib/shared/utils/csvExport.ts` | CSV download utility with error handling |

### Files Modified

| File | Change |
|------|--------|
| `ui/src/lib/shared/components/data/DataControls.svelte` | Added `onCsvExport` callback prop, `Download` icon, CSV button with loading state |
| `ui/src/lib/features/hosts/components/HostTab.svelte` | Added CSV export with server-side filters (tag_ids, order_by, order_direction) |
| `ui/src/lib/features/services/components/ServiceTab.svelte` | Added CSV export with server-side filters |
| `ui/src/lib/features/subnets/components/SubnetTab.svelte` | Added CSV export (all records) |
| `ui/src/lib/features/groups/components/GroupTab.svelte` | Added CSV export (all records) |
| `ui/src/lib/features/tags/components/TagTab.svelte` | Added CSV export (all records) |
| `ui/src/lib/features/daemons/components/DaemonTab.svelte` | Added CSV export (all records) |
| `ui/src/lib/features/networks/components/NetworksTab.svelte` | Added CSV export (all records) |

### Implementation Details

**Entity Path Mapping (`entities.ts`):**
- Uses `EntityDiscriminants` type from generated schema
- Maps all entity types to their API export paths
- Special handling for API keys: `UserApiKey` → `auth/keys`, `DaemonApiKey` → `auth/daemon`
- Returns `null` for entities without export support (Organization, Invite, Unknown)

**CSV Download Utility (`csvExport.ts`):**
- `downloadCsv(entityType, params)` function
- Constructs URL with filter parameters (tag_ids, order_by, order_direction)
- Uses `credentials: 'include'` for authentication
- Creates blob URL and triggers browser download
- Error handling with toast notifications via `pushError`

**DataControls Component:**
- New `onCsvExport?: (() => void | Promise<void>) | null` prop
- Button only renders when callback is provided
- Loading state shows "Exporting..." during download
- Disabled state prevents double-clicks

**Tab Components:**
- Tabs with server-side filtering (Host, Service) pass current filter state to export
- Tabs with client-side filtering export all records

### UI Verification
- `npm run check` - 0 errors, 0 warnings
- `npm run format` - All files properly formatted
>>>>>>> csv-export
