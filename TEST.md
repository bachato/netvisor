# Test Plan for Pending Branches

This document contains the test plan for branches pending merge to `dev`.

**API Testing Credentials:**
```
API Key: scp_u_YANq5G2OLn7zir5ixPydwe3WrXOsaWyw
Network ID: b19b9406-8e6e-44ed-a68e-c65e7738ff09
```

---

## #463 - Interface Filter (`463-interface-filter`)

**What Changed:** `SCANOPY_INTERFACES` env var now correctly maps to `interfaces` config field

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Env var parsing | 1. Set `SCANOPY_INTERFACES=eth0,eth1`<br>2. Start daemon<br>3. Check logs or config endpoint | `interfaces: ["eth0", "eth1"]` in config |
| Single interface | 1. Set `SCANOPY_INTERFACES=enp6s18`<br>2. Run network discovery | Only scans via `enp6s18`, ignores other interfaces |
| CLI flag still works | 1. Run daemon with `--interfaces eth0`<br>2. Check config | `interfaces: ["eth0"]` |
| Empty/unset | 1. Don't set `SCANOPY_INTERFACES`<br>2. Start daemon | Scans all interfaces (default behavior) |
| Unit tests | `cd backend && cargo test daemon::shared::config` | All tests pass |

**Automated:** `cargo test` includes regression test `test_scanopy_interfaces_env_var`

---

## #455 - Scan Rate (`455-scan-rate`)

**What Changed:** Added `scan_rate_pps` config, staggered connection starts, adaptive batch sizing

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Config option exists | 1. Set `SCANOPY_SCAN_RATE_PPS=250`<br>2. Start daemon<br>3. Check config | `scan_rate_pps: 250` |
| Default value | 1. Start daemon without setting env var<br>2. Check config | `scan_rate_pps: 500` (default) |
| Staggering works | 1. Run deep scan on single host<br>2. Monitor with `tcpdump` or Wireshark | SYN packets spaced ~2ms apart (at 500 pps) |
| Adaptive batch sizing | 1. Run deep scan<br>2. Check debug logs | Logs show "Host capacity probed" with varying batch sizes |
| No service disruption | 1. Scan network with web servers<br>2. Access web UI during scan | Web interfaces remain responsive (original issue) |
| Unit tests | `cd backend && cargo test` | All tests pass |

**Manual verification (important):**
```bash
# On a test network, verify services aren't overwhelmed
SCANOPY_LOG_LEVEL=debug SCANOPY_SCAN_RATE_PPS=500 ./daemon
# Watch for "Host capacity probed" logs showing batch size selection
```

---

## #451 - Topology 413 (`451-topology-413`)

**What Changed:** 4 new lightweight endpoints for topology operations

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Node drag (small topology) | 1. Open topology<br>2. Drag node<br>3. Refresh page | Position persisted, no errors |
| Node drag (large topology) | 1. Open topology with 50+ nodes<br>2. Drag node | No 413 error, position saved |
| Node resize | 1. Resize a subnet node<br>2. Refresh | Size persisted |
| Edge reconnect | 1. Reconnect an edge to different handle<br>2. Refresh | Handle position persisted |
| Metadata edit | 1. Edit topology name/parent<br>2. Refresh | Changes persisted |
| API direct test | `curl -X POST -H "X-API-Key: $KEY" -H "Content-Type: application/json" -d '{"network_id":"...", "node_id":"...", "x":100, "y":200}' http://localhost:60072/api/v1/topology/{id}/node-position` | 200 OK |
| Unit tests | `cd backend && cargo test topology`<br>`cd ui && npm test` | All pass |

**Key verification:** Open Network tab in browser DevTools, drag a node, verify request payload is ~100 bytes (not megabytes)

---

## #450 - Pagination (`450-pagination`)

**What Changed:** Page size persists correctly, count display fixed

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Page size persistence | 1. Go to Hosts tab<br>2. Set page size to 100<br>3. Refresh page | Page size still 100 |
| Count display (single page) | 1. Have 15 hosts<br>2. Set page size to 20 | Shows "Showing 15 items" (not "15 of 20") |
| Count display (multi-page) | 1. Have 45 hosts<br>2. Set page size to 20 | Shows "Showing 1-20 of 45 items" |
| Grouping + pagination | 1. Group hosts by field<br>2. Change page size<br>3. Navigate pages | Groups persist, counts accurate |
| Different tabs | Test on Hosts, Services, Subnets tabs | All persist correctly |
| Unit tests | `cd ui && npm test` | All 14 tests pass |

---

## #449 - Host Icons (`449-host-icons`)

**What Changed:** `useServicesCacheQuery()` reads from correct cache key

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Host with services shows icon | 1. Have host with HTTP service<br>2. View hosts list | Host shows HTTP icon (not question mark) |
| Host without services | 1. Have host with no services<br>2. View hosts list | Host shows default Host icon |
| Docker hosts | 1. Have Docker-discovered host<br>2. View hosts list | Shows Docker/container services |
| Deco/network devices | 1. Have network device<br>2. View hosts list | Services display correctly |
| Services column populated | 1. View hosts table<br>2. Check Services column | Services listed (not empty) |
| No network requests for services | 1. Open Network tab<br>2. Navigate to Hosts | No separate `/api/v1/services` call (uses cache) |
| Unit tests | `cd ui && npm test` | All pass |

---

## #438 - Daemon Push Mode (`438-daemon-push`)

**What Changed:** Added Inbound mode where server initiates all connections

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Outbound mode (existing) | 1. Set `SCANOPY_DAEMON_MODE=Outbound`<br>2. Start daemon | Daemon connects to server, heartbeats work |
| Push/Pull aliases | 1. Set `SCANOPY_DAEMON_MODE=Push`<br>2. Start daemon | Works (deprecated alias for Outbound) |
| Inbound mode - daemon startup | 1. Pre-provision daemon in server<br>2. Set `SCANOPY_DAEMON_MODE=Inbound`<br>3. Start daemon | Daemon does NOT connect to server |
| Inbound mode - server polling | 1. Configure Inbound daemon<br>2. Check server logs | Server polls daemon's `/api/status` |
| Inbound mode - discovery | 1. Trigger discovery from UI<br>2. Monitor | Server calls daemon's `/api/discovery/initiate` |
| Daemon status endpoint | `curl http://localhost:60073/api/status` | Returns daemon status JSON |
| Daemon results endpoint | `curl http://localhost:60073/api/discovery/results` | Returns buffered entities (or empty) |
| Migration | Check migration `20260116100000_daemon_api_key_link.sql` applied | No errors |
| Unit tests | `cd backend && cargo test daemon`<br>`cd backend && cargo test server::daemons` | All pass |

**Important:** This is a significant architectural change. Test both modes thoroughly.

---

## CSV Export (`csv-export`)

**What Changed:** CSV export endpoints for all entities

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Hosts CSV | `curl -H "X-API-Key: $KEY" http://localhost:60072/api/v1/hosts/export/csv -o hosts.csv` | Valid CSV with host data |
| Filtered export | `curl -H "X-API-Key: $KEY" "http://localhost:60072/api/v1/hosts/export/csv?network_id=$NID"` | Only hosts from that network |
| Services CSV | `curl -H "X-API-Key: $KEY" http://localhost:60072/api/v1/services/export/csv` | Valid CSV, no nested bindings |
| Daemons CSV (sensitive fields) | Export daemons CSV | No `url` field (contains secrets) |
| Users CSV (sensitive fields) | Export users CSV | No `password_hash` field |
| UI export button | 1. Go to Hosts tab<br>2. Click CSV export button | File downloads |
| UI with filters | 1. Apply tag filter<br>2. Click CSV export | Exported CSV respects filter |
| Large export | Export entity with 1000+ records | Completes without timeout |
| Auth required | `curl http://localhost:60072/api/v1/hosts/export/csv` (no auth) | 401/403 |
| Unit tests | `cd backend && cargo test`<br>`cd ui && npm test` | All pass |

**Entities to spot-check:** Host, Service, Subnet, Interface, Port, Daemon, User, Network

---

## SNMP Support (`snmp-support`)

**What Changed:** Full SNMP discovery support with credentials, ifTable collection, LLDP/CDP neighbor discovery, and PhysicalLink topology edges

### SNMP Credentials

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Create credential | 1. Go to Settings > SNMP Credentials<br>2. Create credential with name + community string | Credential created, community masked |
| Edit credential | Edit existing credential | Updates saved |
| Delete credential | Delete unused credential | Credential removed |
| Delete in-use credential | Delete credential assigned to network | Blocked or cascades appropriately |
| API CRUD | `curl -X POST -H "X-API-Key: $KEY" -d '{"name":"test","community":"public","version":"V2c"}' http://localhost:60072/api/v1/snmp-credentials` | 201 Created |

### Network SNMP Settings

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Assign default credential | 1. Edit network<br>2. Select SNMP credential | `snmp_credential_id` set on network |
| Clear credential | Remove credential from network | `snmp_credential_id` null |
| Discovery uses credential | 1. Set network credential<br>2. Run discovery on SNMP device | SNMP data collected |

### Host SNMP Override

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Override network default | 1. Edit host<br>2. Set different SNMP credential | Host uses override, not network default |
| Clear override | Remove credential from host | Falls back to network default |
| SNMP tab visibility | Edit existing host | SNMP tab visible with credential selector |

### SNMP Discovery (requires SNMP-enabled device)

| Test | Steps | Expected Result |
|------|-------|-----------------|
| System MIB collection | 1. Configure credential<br>2. Run discovery on switch/router | Host has `sys_descr`, `sys_object_id`, `sys_location`, `sys_contact` |
| sysName → hostname | Run discovery on device with sysName | Host `hostname` populated from sysName |
| Vendor identification | Check host after discovery | Vendor derived from sysObjectID (IANA enterprise lookup) |
| Chassis ID (LLDP) | Run discovery on LLDP-enabled device | Host has `chassis_id` populated |

### IfEntry (SNMP Interfaces)

| Test | Steps | Expected Result |
|------|-------|-----------------|
| ifTable collection | Run discovery on managed switch | Host has `if_entries` array populated |
| IfEntry fields | Check IfEntry in host detail | Has `if_index`, `if_descr`, `if_type`, `if_alias`, `admin_status`, `oper_status`, `speed_bps` |
| ifType lookup | Check IfEntry | `if_type` resolves to name (e.g., 6 → "ethernetCsmacd") |
| MAC address | Check IfEntry with physical port | `mac_address` populated (hydrated from mac_addresses table) |
| IfEntry → Interface link | IfEntry with IP address | `interface_id` links to corresponding Interface entity |
| IfEntries tab | Edit host with if_entries | "SNMP Interfaces" tab visible, sorted by ifIndex |
| API endpoint | `curl -H "X-API-Key: $KEY" http://localhost:60072/api/v1/if-entries?host_id=...` | Returns IfEntry array |

### LLDP/CDP Neighbor Discovery

| Test | Steps | Expected Result |
|------|-------|-----------------|
| LLDP neighbor detection | Run discovery on two connected LLDP switches | Both have if_entries with `neighbor` populated |
| CDP neighbor detection | Run discovery on Cisco device | CDP neighbors discovered |
| Neighbor resolution | Check IfEntry with neighbor | `neighbor` field shows `IfEntry(uuid)` pointing to remote port |
| Bidirectional links | Check both ends of a link | Both IfEntries reference each other |

### PhysicalLink Topology Edges

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Edge creation | 1. Discover LLDP-connected switches<br>2. View topology | PhysicalLink edges appear between switch ports |
| Edge style | Check PhysicalLink edge | Cyan color, solid line, bidirectional |
| Edge label | Hover over PhysicalLink edge | Shows port descriptions (e.g., "Gi0/1 ↔ Gi0/2") |
| Edge metadata | Inspect edge JSON | Has `is_physical_edge: true`, `protocol: "LLDP"` or `"CDP"` |

### MAC Address Table

| Test | Steps | Expected Result |
|------|-------|-----------------|
| MAC deduplication | Same MAC from ARP and SNMP | Single entry in `mac_addresses` table |
| Discovery source tracking | Check MAC record | Has `arp_discovered_at` and/or `snmp_discovered_at` |
| Interface MAC hydration | GET host with interfaces | Interfaces have `mac_address` string (not just `mac_address_id`) |

### Migrations

| Test | Steps | Expected Result |
|------|-------|-----------------|
| mac_addresses table | Check schema | Table exists with unique MAC constraint |
| snmp_credentials table | Check schema | Table exists with org FK |
| if_entries table | Check schema | Table exists with host FK, unique(host_id, if_index) |
| Interface migration | Check interfaces table | `mac_address_id` FK instead of `mac_address` column |
| Host SNMP fields | Check hosts table | Has `sys_descr`, `sys_object_id`, `chassis_id`, etc. |

### Unit Tests

```bash
cd backend && cargo test snmp
cd backend && cargo test if_entries
cd backend && cargo test mac_address
```

**Manual verification (requires SNMP device):**
```bash
# Test SNMP collection directly
SCANOPY_LOG_LEVEL=debug ./daemon
# Trigger discovery, watch for "SNMP polling" and "ifTable walk" logs
```

---

## Quick Verification Commands

```bash
# Run all backend tests
cd backend && cargo test

# Run all UI tests
cd ui && npm test

# Verify each branch compiles
for dir in scanopy-463-interface-filter scanopy-455-scan-rate scanopy-451-topology-413 scanopy-450-pagination scanopy-449-host-icons scanopy-438-daemon-push scanopy-csv-export scanopy-snmp; do
  echo "=== Testing $dir ==="
  cd /Users/maya/dev/$dir
  cargo check && echo "✓ $dir backend OK"
  cd ui && npm run check && echo "✓ $dir frontend OK"
  cd /Users/maya/dev/scanopy
done
```

---

## Risk Assessment

| Branch | Risk | Reason |
|--------|------|--------|
| #463 | Low | Simple config fix |
| #455 | Medium | Changes scanning behavior - test on real network |
| #451 | Low | Additive endpoints, existing behavior unchanged |
| #450 | Low | UI state management fix |
| #449 | Low | Cache key fix |
| #438 | **High** | New daemon mode, migration, architectural change |
| CSV | Low | Additive feature |
| SNMP | **High** | New entity types, migrations, discovery changes, topology integration |

**Recommendation:** Test #438 and SNMP most thoroughly before merging. Both have migrations and architectural changes.

---

## Recommended Merge Order

1. **#463** - Interface Filter (independent, low risk)
2. **#450** - Pagination (UI, blocks #449)
3. **#449** - Host Icons (UI, depends on #450)
4. **#455** - Scan Rate (backend)
5. **#451** - Topology 413 (backend + frontend)
6. **CSV Export** - (independent)
7. **#438** - Daemon Push (high risk, has migration)
8. **SNMP** - (highest risk - new entities, multiple migrations, merge last)
