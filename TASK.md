> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Add Server Startup Logging (Match Daemon Style)

## Objective

Add startup and state logging to the server binary, matching the style/flavor of logging already present in the daemon.

## Requirements

### Phase 1: Review Daemon Logging

Study the existing daemon logging to understand the style and what information is logged:

1. **`backend/src/bin/daemon.rs`** - Main daemon entry point
   - What's logged at startup?
   - What state transitions are logged?
   - What format/structure is used?

2. **`backend/src/daemon/runtime/service.rs`** - Daemon runtime service
   - What service lifecycle events are logged?
   - How are configuration values displayed?
   - What's the logging level strategy (info vs debug vs trace)?

Document the patterns you find.

### Phase 2: Apply to Server

Add similar logging to the server:

1. **`backend/src/bin/server.rs`** - Main server entry point
   - Log startup banner/version info
   - Log configuration values (listening address, ports, enabled features)
   - Log state transitions (initializing → ready → serving)
   - Log key milestones (database connected, migrations run, routes registered)

2. **Other server initialization code** - Follow the call chain from server.rs
   - Identify methods that would benefit from startup logging
   - Add logging for significant initialization steps
   - Examples: database pool creation, service initialization, scheduler startup

### Logging Guidelines

- **Match the daemon's style** - Use similar log levels, message formats, field structures
- **Be informative, not verbose** - Log what operators need to see at startup
- **Use structured logging** - `tracing::info!(field = value, "message")` format
- **Consider log levels**:
  - `info!` - Key startup milestones operators should see
  - `debug!` - Detailed config values, internal state
  - `trace!` - Very detailed initialization steps

## Key Files

| Purpose | File |
|---------|------|
| Daemon entry point (reference) | `backend/src/bin/daemon.rs` |
| Daemon runtime (reference) | `backend/src/daemon/runtime/service.rs` |
| Server entry point (update) | `backend/src/bin/server.rs` |
| Server initialization | Follow calls from server.rs |

## Acceptance Criteria

- [ ] Daemon logging patterns documented
- [ ] Server startup logs key information (version, config, listening address)
- [ ] Server logs state transitions (initializing → ready)
- [ ] Relevant initialization methods have appropriate logging
- [ ] Logging style matches daemon (consistent across binaries)
- [ ] `cargo test` passes
- [ ] `make format && make lint` passes

## Notes

- This is about improving operator experience - good startup logs help with debugging deployment issues.
- Don't over-log. Match the daemon's level of detail, not more.
- Consider what an operator would want to see when the server starts successfully vs when something fails.

---

## Work Summary

### Implemented

Added daemon-style startup logging to the server binary, matching the existing daemon patterns.

**Files changed:**
- `backend/src/bin/server.rs` - Main server entry point

### Changes Made

1. **Startup Banner** - Added ASCII art logo matching daemon style
2. **LOG_TARGET constant** - Added `"server"` log target for consistent filtering
3. **Initialization Logging** - State transitions during startup:
   - "Initializing..."
   - "Connecting to database..."
   - "Database connected, migrations applied"
   - "Services initialized"
   - "Background tasks started"
   - "Routes registered"
   - "Discovery scheduler started"
   - "Billing service initialized" (if enabled)
4. **Configuration Summary** - Key settings logged:
   - Listen address
   - Public URL
   - Log level
   - Deployment type (Cloud/Commercial/Community)
   - Web UI status
   - Integrated daemon URL (if configured)
   - Billing status (if enabled)
   - OIDC status (if enabled)
   - Secure cookies status (if HTTPS)
5. **Ready Message** - Clear "Server ready" with API/UI URLs
6. **Shutdown Logging** - "Shutdown signal received" / "Server stopped"

### Daemon Patterns Applied

| Pattern | Implementation |
|---------|----------------|
| ASCII banner | Same Scanopy logo as daemon |
| Separator lines | `━━━━━━...` visual dividers |
| Key-value format | `  Label:          value` (aligned) |
| LOG_TARGET | `target: LOG_TARGET` on all log statements |
| State transitions | Initializing → Configuration → Ready |
| Shutdown messages | Ctrl+C handling with final message |

### Deviations

- None. Followed daemon style exactly.

### Testing

- `cargo fmt` - Passed
- `cargo clippy` - Passed (pre-existing warnings only)
- `cargo test` - All tests pass

### Example Output

```
   _____
  / ___/_________ _____  ____  ____  __  __
  \__ \/ ___/ __ `/ __ \/ __ \/ __ \/ / / /
 ___/ / /__/ /_/ / / / / /_/ / /_/ / /_/ /
/____/\___/\__,_/_/ /_/\____/ .___/\__, /
                           /_/    /____/

Scanopy Server v0.13.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Initializing...
  Connecting to database...
  Database connected, migrations applied
  Services initialized
  Background tasks started
  Routes registered
  Discovery scheduler started
Configuration:
  Listen:          0.0.0.0:60072
  Public URL:      http://localhost:60072
  Log level:       info
  Deployment:      Community
  Web UI:          enabled
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Server ready
  API:             http://localhost:60072/api
  Web UI:          http://localhost:60072
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
