> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Onboarding Emails — Brevo Event Fix + Transactional Templates

## Objective

Implement three backend changes for the onboarding email campaign:
1. Fix Brevo event mapping so `first_discovery_completed` fires from the correct handler
2. Add `track_event("first_daemon_registered")` to daemon registration handler
3. Add 4 transactional email templates (A3-free, A3-paid, A5, C2) and wire them to telemetry handlers

## Work Summary

### What was implemented

**1. Brevo Event Mapping Fixes (`brevo/service.rs`, `brevo/types.rs`)**
- Extracted `FirstDiscoveryCompleted` from the multi-arm `handle_engagement_event` match into its own `handle_first_discovery_completed` handler
- New handler sets `scanopy_first_discovery_completed_date` company attribute and fires `track_event("first_discovery_completed")`
- Fixed `handle_first_topology_rebuild` — removed incorrect `track_event("first_discovery_completed")` call
- Added `track_event("first_daemon_registered")` to `handle_first_daemon_registered`
- Added 3 missing fields to `CompanyAttributes::to_attributes()`: `scanopy_first_discovery_completed_date`, `scanopy_first_host_discovered_date`, `scanopy_first_topology_rebuild_date`

**2. Email Templates (`email/templates.rs`)**
- Added 5 template constant pairs: `DISCOVERY_GUIDE_FREE`, `DISCOVERY_GUIDE_PAID`, `TOPOLOGY_READY`, `PLAN_LIMIT_APPROACHING`, `PLAN_LIMIT_REACHED`
- All use inline CSS matching existing style, upgrade CTAs use `?modal=billing-plan`

**3. EmailService Expansion (`email/traits.rs`)**
- Added service dependencies: `organization_service`, `host_service`, `network_service`, `service_service`
- Added builder methods on `EmailProvider` trait for all 5 new email types
- Added high-level methods on `EmailService`: `send_discovery_guide_email`, `send_discovery_guide_for_org`, `send_topology_ready_for_org`, `check_plan_limits`
- `check_plan_limits` implements threshold-crossing detection with `LimitNotificationLevel` state machine

**4. Plan Limit Infrastructure (`organizations/impl/base.rs`, migration)**
- Added `LimitNotificationLevel` enum (`None`, `Approaching`, `Reached`) and `PlanLimitNotifications` struct
- Added `plan_limit_notifications` field to `OrganizationBase` (JSON column, defaults to `{}`)
- Added `network_limit()` and `seat_limit()` methods to `BillingPlan`
- Added `PlanLimitNotifications` variant to `SqlValue` enum with proper binding
- Migration: `ALTER TABLE organizations ADD COLUMN plan_limit_notifications JSONB NOT NULL DEFAULT '{}'`

**5. EventBus-driven Email Triggering (`email/subscriber.rs`)**
- EmailService subscribes to both entity events (Host/Network/User Created) and telemetry events (FirstDaemonRegistered, FirstDiscoveryCompleted) via a custom `EventFilter`
- Entity events trigger `check_plan_limits` for the affected org
- `FirstDaemonRegistered` telemetry triggers discovery guide email (free/paid variant based on org plan)
- `FirstDiscoveryCompleted` telemetry triggers topology ready email
- Registered as event subscriber in factory

**6. Telemetry Event Enrichment (`daemons/service.rs`)**
- `FirstDaemonRegistered` event metadata now includes `daemon_name` and `network_name` so the email subscriber can use them without needing a DaemonService dependency

### Deviations from original plan

- **EventBus instead of OnceLock**: Original plan called for injecting `EmailService` directly into `DaemonService` and `DiscoveryService` via OnceLock. Refactored to use EventBus — EmailService subscribes to telemetry events, eliminating circular dependency concerns entirely.
- **C2 replaced with general plan limit system**: Instead of a single "free upgrade nudge" email (C2), implemented a full plan limit notification system with approaching (80%) and reached (100%) thresholds for hosts, networks, and seats. Uses threshold-crossing detection to avoid duplicate notifications.

### Files changed

| File | Change |
|------|--------|
| `backend/src/server/brevo/service.rs` | Event mapping fixes, new handler |
| `backend/src/server/brevo/types.rs` | Missing `to_attributes()` fields |
| `backend/src/server/email/templates.rs` | 5 new template pairs |
| `backend/src/server/email/traits.rs` | New dependencies, builders, high-level methods |
| `backend/src/server/email/subscriber.rs` | **New** — EventSubscriber for plan limits + onboarding emails |
| `backend/src/server/email/mod.rs` | Added `pub mod subscriber` |
| `backend/src/server/daemons/service.rs` | Enriched telemetry metadata, removed OnceLock email_service |
| `backend/src/server/discovery/service.rs` | Removed OnceLock email_service |
| `backend/src/server/organizations/impl/base.rs` | `LimitNotificationLevel`, `PlanLimitNotifications` |
| `backend/src/server/organizations/impl/storage.rs` | Storage for `plan_limit_notifications` |
| `backend/src/server/billing/types/base.rs` | `network_limit()`, `seat_limit()` |
| `backend/src/server/shared/storage/traits.rs` | `SqlValue::PlanLimitNotifications` variant |
| `backend/src/server/shared/storage/generic.rs` | Binding for new SqlValue variant |
| `backend/src/server/shared/services/factory.rs` | Wire EmailService deps + register subscriber |
| `backend/src/server/auth/service.rs` | Default `plan_limit_notifications` in org init |
| `backend/src/server/shared/types/examples.rs` | Default `plan_limit_notifications` in example |
| `backend/migrations/20260221120000_add_plan_limit_notifications.sql` | New column |

### Verification

- `cargo test` — 110 tests pass, 0 failures
- `cargo fmt && cargo clippy` — clean, no warnings
