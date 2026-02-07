> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Investigate & Fix Integrated Daemon Connection Issues (v0.14.0+)

## Objective

Since v0.14.0 (which changed daemon mode from push/pull to serverpoll/daemonpoll), multiple users report the integrated Docker Compose daemon fails to connect to the server. v0.13.6 worked fine. Investigate the end-to-end flow, identify the root cause(s), and fix them.

**GitHub issues:** #495, #493

## Problem Reports

Multiple users on Discord report the same issue. Here are the key data points:

### User 1 (Tchoupie)
- Default daemon not showing after setup
- Docker gateway was `192.168.0.1` (not the typical `172.x.x.x`)
- Worked on a Multipass VM with the same compose without changes
- Failed on a host where the Docker bridge gateway isn't `172.x.x.x`

### User 2 (yeeclaw)
- Same issue, stock Docker Compose from docs, Docker gateway is `172.17.0.1`
- v0.14.0 and v0.14.1 both affected
- Adding `SCANOPY_MODE: daemon_poll` produced a new error — daemon tried to reach `http://127.0.0.1:60072` which fails in Docker (separate containers)
- Adding `SCANOPY_SERVER_URL` didn't immediately fix it
- Eventually got it working but reported a **race condition**: server depended on daemon health, but daemon couldn't be healthy without server connection
- Remote daemon on different subnet also failing with connection errors

### User 3 (travioli)
- Same issue with v0.14.0–v0.14.2
- v0.13.6 works fine with default Docker Compose
- Got it working with specific compose changes (added `SCANOPY_MODE: daemon_poll` and `SCANOPY_SERVER_URL`)

### User 4 (barnacle)
- Remote daemon on different subnet can't connect
- Can curl/ping/telnet the server fine from daemon host
- Connection fails from daemon to server at the application level

## Investigation Required

Trace the entire daemon connection flow end-to-end. Specifically:

### 1. Docker Compose Defaults
- Read `docker-compose.yml`. What's the default `SCANOPY_MODE`? What's the default `SCANOPY_SERVER_URL` for the daemon? How do containers reach each other?
- Is there a circular health check dependency (server waits for daemon, daemon waits for server)?

### 2. Daemon Mode Defaults
- `DaemonMode` enum has `#[default] DaemonPoll`. But does the Docker Compose or daemon CLI override this?
- The enum uses `#[serde(alias = "push")] ServerPoll` and `#[serde(alias = "pull")] DaemonPoll` for JSON deserialization. But the CLI uses clap `ValueEnum` with `#[value(rename_all = "snake_case")]`. Does the env var `SCANOPY_MODE` support "push"/"pull" or only "server_poll"/"daemon_poll"?
- If old configs (pre-v0.14.0) used `push`/`pull` values, do they still work via env var?

### 3. Daemon Startup & Registration
- Trace `backend/src/bin/daemon.rs` startup flow
- How does the daemon register with the server? What endpoint does it call?
- What's different between DaemonPoll and ServerPoll startup?
- For DaemonPoll: daemon must know the server URL and actively connect
- For ServerPoll: server must know daemon URL and connect to it — does the integrated compose provide this?

### 4. Server URL Resolution
- How does the daemon determine the server URL? Default value?
- In Docker Compose, `localhost`/`127.0.0.1` points to the daemon's own container, not the server. Is the default URL `http://localhost:60072`? That would explain the `Connection refused` errors.

### 5. v0.14.0 Change Impact
- Look at git history for the push/pull → serverpoll/daemonpoll change
- Did the default mode or default server URL change?
- Were Docker Compose files updated to match?

### 6. Docker Gateway Issue
- Some users have non-standard Docker bridge gateways (192.168.x.x instead of 172.x.x.x). Why does this matter? Is the compose relying on a specific gateway IP?

## Expected Deliverables

1. **Root cause analysis** documenting each issue found, with file paths and line numbers
2. **Fix the Docker Compose** (`docker-compose.yml`) so integrated daemon works out of the box:
   - Correct default mode
   - Correct server URL for inter-container communication
   - No race condition in health checks
   - Works regardless of Docker bridge gateway IP
3. **Fix any code issues** (e.g., default values, env var parsing, backward compat for push/pull values)
4. **Test the fix** by verifying the compose config would work in the scenarios described above

## Key Files to Investigate

- `docker-compose.yml` — compose config
- `backend/src/bin/daemon.rs` — daemon entrypoint
- `backend/src/daemon/` — daemon runtime, config, polling
- `backend/src/server/daemons/impl/base.rs` — `DaemonMode` enum
- `backend/src/server/daemons/handlers.rs` — registration, request-work endpoints
- `backend/src/server/daemons/service.rs` — polling loop, startup
- `backend/src/daemon/shared/config.rs` — daemon config (server URL, mode)
- Any CLI arg parsing for daemon (clap derive structs)

---

## Work Summary

### Root Causes

Three issues prevented the integrated Docker Compose daemon from connecting:

1. **Hardcoded Docker bridge gateway IP** — `SCANOPY_INTEGRATED_DAEMON_URL` used `172.17.0.1`, which varies by system (e.g., `192.168.0.1`). When wrong, `initialize_local_daemon()` silently fails and the daemon never receives credentials.

2. **Race condition on restart** — Server had `depends_on: daemon: condition: service_healthy`, but daemon's `initialize_services()` call to the server used `?` error propagation. If server wasn't up yet, daemon crashed → health check failed → server never started → deadlock.

3. **Minor compose cleanup** — Daemon `ports` section was a no-op with `network_mode: host`. `SCANOPY_PORT` env var mapped to the wrong config field (Figment maps it to `port`, but the field is `daemon_port`).

### Files Changed

**`docker-compose.yml`**
- Replaced `http://172.17.0.1:...` with `http://host.docker.internal:...` for `SCANOPY_INTEGRATED_DAEMON_URL`
- Added `extra_hosts: ["host.docker.internal:host-gateway"]` to server service (Docker Engine 20.10+)
- Changed `depends_on: daemon: condition: service_healthy` → `service_started`
- Removed daemon `ports` section (no-op with `network_mode: host`)
- Removed `SCANOPY_PORT` env var (redundant with `SCANOPY_DAEMON_PORT`)

**`backend/src/bin/daemon.rs`** (lines 136-143)
- Changed `initialize_services().await?` to log a warning on failure instead of crashing. The `request_work()` polling loop already retries with exponential backoff.

**`backend/src/server/daemons/impl/base.rs`** (lines 132, 137)
- Added `#[value(alias = "push")]` on `ServerPoll` and `#[value(alias = "pull")]` on `DaemonPoll` for CLI/env var backward compatibility with pre-v0.14.0 mode names.

### Verification
- 114 backend tests pass, 0 failures
- `cargo fmt` clean
- `cargo clippy -D warnings` clean
