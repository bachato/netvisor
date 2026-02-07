> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Billing Experience Overhaul

## Objective

Overhaul the billing experience: add a Free tier, remove credit card requirement at signup, show plan selection as an in-app modal instead of a gating page, allow plan changes from within the UI, add payment method collection flow, add notification bubble for missing billing, add transactional emails for billing lifecycle events, and enforce Free tier limitations in both backend and frontend.

---

## 1. Free Tier Plan

### BillingPlan Enum

Add `Free(PlanConfig)` variant to `BillingPlan` in `backend/src/server/billing/types/base.rs`.

**PlanConfig for Free:**
```rust
BillingPlan::Free(PlanConfig {
    base_cents: 0,
    rate: BillingRate::Month,
    trial_days: 0,
    seat_cents: None,
    network_cents: None,
    host_cents: None,         // NEW FIELD - can't buy more
    included_seats: Some(1),
    included_networks: Some(1),
    included_hosts: Some(25), // NEW FIELD - capped at 25
})
```

### New PlanConfig Fields

Add to `PlanConfig` following the existing pattern for seats/networks:
- `host_cents: Option<i64>` — None = can't pay for more. Set to `None` for all plans (no host add-on pricing).
- `included_hosts: Option<u64>` — None = unlimited. `Some(25)` for Free, `None` for all others.

Update all existing plan definitions in `plans.rs` to include `host_cents: None, included_hosts: None`.

### Remove Redundant Feature Flags

`unlimited_hosts` and `unlimited_scans` are now redundant — host limits are expressed by `included_hosts` in PlanConfig, and scan scheduling by `scheduled_discovery` in BillingPlanFeatures. Remove:
- `unlimited_hosts` and `unlimited_scans` fields from `BillingPlanFeatures` struct
- `UnlimitedHosts` and `UnlimitedScans` variants from the `Feature` enum in `features.rs`
- All associated trait impls, match arms, `Into<Vec<Feature>>` entries, and references
- The pricing page / fixtures should show host limits from `PlanConfig.included_hosts` and discovery from `scheduled_discovery` instead

### New BillingPlanFeatures Fields

Add:
- `scheduled_discovery: bool` — false for Free, true for all other plans
- `daemon_poll: bool` — false for Free, true for all other plans

### New Feature Enum Variants

Add to `Feature` in `features.rs`:
- `ScheduledDiscovery` — category: "Core", name: "Scheduled Discovery", description: "Schedule automatic network discovery scans"
- `DaemonPoll` — category: "Core", name: "DaemonPoll Mode", description: "Daemon-initiated polling — no open ports required on the daemon"

Update all trait impls: `HasId`, `EntityMetadataProvider`, `TypeMetadataProvider`, `Into<Vec<Feature>>`.

### New ErrorCode Variants

Add to `ErrorCode` in `shared/types/error_codes.rs` under the `// === Billing ===` section:
- `BillingHostLimitReached { limit: u32 }` — "You've reached the limit of {limit} hosts on your current plan. Upgrade for unlimited hosts."
- `BillingFeatureNotAvailable { feature: String }` — "Your current plan does not include {feature}. Upgrade your plan to access this feature."

And under `// === Daemon ===`:
- `DaemonStandby` — "Your plan does not support DaemonPoll mode. The daemon is on standby. Upgrade your plan and restart the daemon to resume."

Add corresponding entries in `default_message()`, `params()`, and the no-params match arm.

### Update All BillingPlan Match Arms

Add `Free` to every match in `BillingPlan` impl blocks:
- `config()`, `set_config()`, `is_commercial()` → false
- `can_invite_users()` → false (1 seat, no seat_cents)
- `hosting()` → `Hosting::Cloud`
- `custom_price()` → `Some("Free")`
- `stripe_product_id()`, all stripe lookup key methods
- `features()` — same as Starter except: `scheduled_discovery: false`, `daemon_poll: false`
- `EntityMetadataProvider`: icon (appropriate variant), color (`Color::Green`)
- `TypeMetadataProvider`: name "Free", description "Get started with Scanopy — manual discovery for up to 25 hosts"

### plans.rs

Add `get_free_plan() -> BillingPlan`. Include Free in `get_purchasable_plans()` (frontend needs it in the plan selection modal) and `get_website_fixture_plans()`.

### Tests

The existing `test_feature_ids_match_billing_plan_features_fields` test catches Feature/BillingPlanFeatures mismatches. Ensure it passes.

---

## 2. Backend Enforcement of Free Tier Limits

### Host Limit

Use `ApiError::coded(StatusCode::FORBIDDEN, ErrorCode::BillingHostLimitReached { limit })`.

**Discovery host creation:** In `server/hosts/service.rs` — in the code path where the host service checks for existing/conflicting hosts and decides whether to create a new one or upsert data to an existing one: if creating a NEW host, check the organization's `included_hosts` from plan config against current host count. If at or over limit, return the error AND cancel the active discovery session via the discovery service. If UPSERTING an existing host (just updating data), allow it to proceed — no limit check needed.

**Manual host creation:** In `server/hosts/handlers.rs` — the create host endpoint used by the UI should check the limit in the handler before proceeding.

### Scheduled Discovery Restriction

Use `ApiError::coded(StatusCode::FORBIDDEN, ErrorCode::BillingFeatureNotAvailable { feature: "Scheduled Discovery".into() })`.

In discovery creation/update handlers (`server/discovery/` handlers), check `plan.features().scheduled_discovery`. If `RunType::Scheduled` is requested and feature is false, return the error.

**On downgrade to Free:** Convert existing `RunType::Scheduled` discoveries to `RunType::AdHoc` (not just disable them — a disabled scheduled discovery could be re-enabled by the user). Converting to AdHoc means the discovery update handler's check will block any attempt to change it back to Scheduled.

### DaemonPoll Restriction

Use `ApiError::coded(StatusCode::FORBIDDEN, ErrorCode::BillingFeatureNotAvailable { feature: "DaemonPoll".into() })`.

In daemon registration (`server/daemons/handlers.rs` — `process_registration()`) and provisioning endpoint, check `plan.features().daemon_poll`. If `DaemonMode::DaemonPoll` is requested and feature is false, return the error.

### Daemon Standby on Downgrade

When an org is downgraded to Free and has active DaemonPoll daemons:

**Server-side:**
- Add `standby: bool` field to `DaemonBase` (default false). On downgrade to Free, set `standby = true` on all DaemonPoll daemons for that org.
- In the server's `poll_daemon()` / `start_polling_loop()` in `daemons/service.rs`, skip daemons where `standby == true` (same pattern as `is_unreachable`).
- When org upgrades to a plan with `daemon_poll: true`, set `standby = false` on their daemons.

**DaemonPoll standby signal — NO response format change. Use an error code instead:**
- In the `request-work` handler (`receive_work_request` in handlers.rs), if `daemon.base.standby` is true, return `ApiError::coded(StatusCode::FORBIDDEN, ErrorCode::DaemonStandby)`.
- This is **backward-compatible**: the response tuple format `(Option<DiscoveryUpdatePayload>, bool)` is unchanged. Old daemons already don't retry `ApiErrorResponse` (see line 211 of `daemon/runtime/service.rs`) and will exit via the generic error handler. New daemons check for `DaemonStandby` specifically.

**New daemon-side standby handling** (in `daemon/runtime/service.rs`, in the error handler around line 236):
- Check if the error is an `ApiErrorResponse` matching `ErrorCode::DaemonStandby`
- If so, log clearly: "Plan does not support DaemonPoll mode. Daemon is on standby. Upgrade your plan and restart the daemon to resume."
- **Block indefinitely** — do NOT exit, so the user sees the message in their terminal. Use something like `tokio::signal::ctrl_c().await` or a pending future.
- The user must manually restart the daemon after upgrading their plan.

### Host Deletion on Downgrade

When an org is downgraded to Free and has more than 25 hosts:
- Delete hosts exceeding the limit
- Keep the 25 most recently updated hosts. Prioritize keeping daemon hosts (identified by `daemon.base.host_id` — check all daemons for the org and preserve their host_ids)
- Include the deletion count in the downgrade email

---

## 3. Frontend Enforcement of Free Tier Limits

### Reusable UpgradeBadge Component

Create `UpgradeBadge.svelte` in `ui/src/lib/shared/components/`:
- Small badge/pill that overlays or sits next to CTA buttons, dropdown options, form fields
- Text like "Upgrade" with tooltip explaining the required plan
- Clicking opens the plan selection modal
- Props: feature name/description (tooltip), optional target plan
- Use consistently across all enforcement points below

### Daemon Mode Selection

In `ui/src/lib/features/daemons/config.ts` and `CreateDaemonForm.svelte`:
- When org plan doesn't have `daemon_poll` feature, disable DaemonPoll option
- Apply UpgradeBadge to the disabled option
- Default to ServerPoll for Free tier

### Discovery Scheduling

In `ui/src/lib/features/discovery/components/DiscoveryModal/DiscoveryTypeForm.svelte`:
- When plan doesn't have `scheduled_discovery`, disable Scheduled run type
- Apply UpgradeBadge
- Only allow AdHoc for Free tier

### Host Limit Indicator

- Show host count vs limit: "X / 25 hosts"
- Warning when approaching (20+/25)
- At limit: disable host creation CTA, apply UpgradeBadge
- "Upgrade for unlimited hosts"

---

## 4. Trial Without Credit Card

**Extend the existing checkout endpoint** (`POST /api/billing/checkout`) — do not create a new endpoint:

- If `trial_days > 0` and new customer: create Stripe Subscription directly via API with `trial_period_days` and no payment method, or use Stripe Checkout with `payment_method_collection: 'if_required'`
- Set `organization.plan`, `plan_status = "trialing"`, `trial_end_date` from Stripe's `subscription.trial_end`
- Publish `TrialStarted` telemetry event
- Return appropriately (no redirect if subscription created directly, or Stripe URL if using checkout mode)

For returning customers or plans without trials, existing checkout flow with card collection remains.

---

## 5. Payment Method Collection

### New Endpoint: `POST /api/billing/setup-payment-method`

- Auth: `Owner`
- Creates Stripe Checkout Session in `setup` mode (collect payment method without charging)
- Returns redirect URL
- On Stripe webhook completion, set `organization.has_payment_method = true`

### New Organization Fields

- `has_payment_method: bool` (default false) — updated via webhooks: `payment_method.attached`, `customer.updated`, or `checkout.session.completed` (setup mode)
- `trial_end_date: Option<DateTime<Utc>>`

Expose both in organization API response.

---

## 6. Trial Expiry and Downgrade to Free

### Stripe Webhook: `customer.subscription.trial_will_end`

Fires 3 days before. Handler:
1. Check `has_payment_method` — only send email if false
2. Send email: "Your trial ends in 3 days. Add a payment method to continue on [Plan]."

### When Trial Expires (no payment method)

Handle in existing `customer.subscription.updated` webhook when transitioning from `trialing`:
1. Downgrade: `plan = Free(...)`, `plan_status = "active"`
2. Cancel Stripe subscription
3. Convert all `RunType::Scheduled` discoveries to `RunType::AdHoc`
4. Set `standby = true` on all DaemonPoll daemons
5. Delete hosts exceeding 25 (keep most recent; preserve daemon host_ids)
6. Compute overage for email:
   - Hosts deleted (count)
   - Discoveries converted to ad-hoc (count)
   - Daemons put on standby (count)
7. Send email with overage: "Your trial has ended. You're on the Free plan. [X hosts removed, Y discoveries converted to manual, Z daemons on standby]. Upgrade anytime."

If `has_payment_method` is true: Stripe handles trial→active normally.

---

## 7. Plan Selection as Modal

### Refactor BillingPlanForm

Convert to modal component:
- Show all plans including Free, "Current Plan" badge on active
- Upgrade/downgrade buttons per plan
- Available app-wide via store or context

### Remove Gating Redirect

Every user now has a plan (Free minimum) — no more 402 lockout. The `/billing` route can open the modal or redirect to settings. Remove 402-based gating flow.

### Post-Onboarding Flow

After registration, user lands on Free. Plan selection modal shown as dismissible suggestion, or notification bubble guides them.

---

## 8. In-App Plan Changes

### New Endpoint: `POST /api/billing/change-plan`

- Auth: `Owner`
- Input: `{ plan: String, rate: String }`
- **Upgrade:** Create checkout/trial or update subscription with proration
- **Downgrade:** Schedule change for end of billing period

### Downgrade Preview: `GET /api/billing/change-plan/preview?plan=...&rate=...`

Returns:
```json
{
  "networks_to_remove": 3,
  "hosts_to_delete": 42,
  "discoveries_to_convert": 5,
  "daemons_to_standby": 2
}
```

### Frontend

- Plan modal: "Current Plan" badge, change buttons
- "Change Plan" on settings billing tab opens modal
- **Downgrade with overage:** Confirmation dialog: "Downgrading to Free will delete 42 hosts (keeping 25), convert 5 scheduled discoveries to manual, and put 2 daemons on standby. This cannot be undone. Continue?"
- User must confirm. Upgrade proceeds directly.

---

## 9. Notification Bubble

Persistent badge on Settings nav item:
- Shows when `has_payment_method === false` AND plan is Free or trialing
- Tooltip: "Add billing information"
- Click navigates to settings billing tab
- Dismisses only when payment method added

### Settings Billing Tab

- Prominent "Add Payment Method" CTA when missing
- Trial countdown from `trial_end_date`
- Free limits: "X / 25 hosts", "Manual discovery only", "ServerPoll only"
- "Change Plan" opens modal

---

## 10. Transactional Emails

Templates in `backend/src/server/email/templates.rs` following existing patterns.

1. **Trial Started** — "Welcome to your [Plan] trial! [X] days to explore."
2. **Trial Ending Soon** (3 days) — "Trial ends in 3 days. Add payment to continue on [Plan]."
3. **Trial Ended / Downgraded** — Include overage: hosts deleted, discoveries converted, daemons on standby. "Upgrade anytime."
4. **Payment Method Added** — "Payment added. Subscription continues after trial."
5. **Plan Changed** — "Upgraded/downgraded to [Plan]. [What changed]."
6. **Subscription Cancelled** — "Cancelled. Access until [date], then Free plan."

Add to `EmailProvider` trait. Implement for Plunk and SMTP. Update `EmailService` subscriber for billing events. The `trial_will_end` webhook calls email service directly (not via EventBus).

---

## 11. Database Migration

Single migration:

```sql
ALTER TABLE organizations ADD COLUMN has_payment_method BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE organizations ADD COLUMN trial_end_date TIMESTAMPTZ;
ALTER TABLE daemons ADD COLUMN standby BOOLEAN NOT NULL DEFAULT FALSE;
```

`included_hosts`, `host_cents` are in JSONB `plan` column via PlanConfig. `scheduled_discovery`, `daemon_poll` are computed from plan via BillingPlanFeatures. No extra columns needed.

---

## 12. Update Billing Fixtures

```bash
cd backend && cargo test generate_billing_fixtures
```

---

## Key Files

**Backend:**
- `billing/types/base.rs` — BillingPlan, PlanConfig, BillingPlanFeatures
- `billing/types/features.rs` — Feature enum
- `billing/plans.rs` — Free plan, get_purchasable_plans
- `billing/service.rs` — checkout, change-plan, setup-payment-method, webhooks
- `billing/handlers.rs` — endpoints
- `shared/types/error_codes.rs` — new ErrorCode variants
- `auth/middleware/billing.rs` — no 402 for Free
- `hosts/service.rs` — host limit (new host vs upsert check) + discovery cancellation
- `hosts/handlers.rs` — manual host creation limit check
- `discovery/` handlers — scheduled discovery restriction
- `daemons/handlers.rs` — DaemonPoll restriction, standby error in request-work
- `daemons/impl/base.rs` — standby field
- `daemons/service.rs` — skip standby in polling loop
- `daemon/runtime/service.rs` — standby error handling (block indefinitely)
- `email/templates.rs` — billing email templates
- `email/traits.rs` — new EmailProvider methods
- `email/subscriber.rs` — billing event routing
- `organizations/impl/base.rs` — has_payment_method, trial_end_date
- `migrations/` — single migration

**Frontend:**
- `shared/components/` — UpgradeBadge.svelte
- `features/billing/BillingPlanForm.svelte` — modal
- `features/billing/queries.ts` — mutations
- `routes/billing/+page.svelte` — remove gating
- `features/settings/BillingTab.svelte` — CTA, countdown, limits
- `features/daemons/config.ts` + `CreateDaemonForm.svelte` — DaemonPoll disabled
- `features/discovery/components/DiscoveryModal/DiscoveryTypeForm.svelte` — Scheduled disabled
- Navigation — notification badge

---

## Acceptance Criteria

- [ ] Free plan with `included_hosts: Some(25)`, `host_cents: None`, `scheduled_discovery: false`, `daemon_poll: false`
- [ ] `unlimited_hosts` and `unlimited_scans` removed from BillingPlanFeatures and Feature enum
- [ ] `PlanConfig` has `included_hosts` and `host_cents` (same pattern as seats/networks)
- [ ] Free in `get_purchasable_plans()` and visible in plan selection UI
- [ ] New users start on Free after onboarding
- [ ] Trials start without credit card via modified checkout endpoint
- [ ] Trial expiry without payment → downgrade to Free, excess hosts deleted
- [ ] Trial expiry email includes overage (hosts deleted, discoveries converted, daemons on standby)
- [ ] `customer.subscription.trial_will_end` webhook sends 3-day reminder
- [ ] ErrorCode variants: `BillingHostLimitReached`, `BillingFeatureNotAvailable`, `DaemonStandby`
- [ ] Host limit: checked on new host creation (not upsert); discovery cancelled when limit hit
- [ ] Manual host creation checks limit in handler
- [ ] Scheduled discoveries converted to AdHoc on downgrade (not just disabled)
- [ ] DaemonPoll daemons set to standby; daemon blocks indefinitely on `DaemonStandby` error (backward-compatible, no tuple format change)
- [ ] Daemon hosts preserved on downgrade (identified via `daemon.base.host_id`)
- [ ] Plan selection is a modal, not a gating page
- [ ] In-app plan changes with downgrade preview + confirmation
- [ ] Payment method collection via settings
- [ ] Notification bubble on settings when no payment method
- [ ] Reusable UpgradeBadge on all restricted features
- [ ] Transactional emails for all billing lifecycle events
- [ ] Tests pass, format/lint clean, fixtures regenerated

---

## Work Summary

### Phase 1: Type System Foundation
- Added `Free(PlanConfig)` variant to `BillingPlan` enum with all required match arms
- Added `host_cents: Option<i64>` and `included_hosts: Option<u64>` to `PlanConfig`
- Replaced `unlimited_scans`/`unlimited_hosts` with `scheduled_discovery`/`daemon_poll` in `BillingPlanFeatures`
- Replaced `UnlimitedScans`/`UnlimitedHosts` with `ScheduledDiscovery`/`DaemonPoll` in `Feature` enum
- Fixed existing bug: `api_access` was pushing `Feature::CustomSso` instead of `Feature::ApiAccess`
- Added `BillingHostLimitReached`, `BillingFeatureNotAvailable`, `DaemonStandby` to `ErrorCode`
- Added `has_payment_method: bool` and `trial_end_date: Option<DateTime<Utc>>` to org base
- Added `standby: bool` to daemon base
- Updated all PlanConfig literals in `plans.rs` with new fields

### Phase 2: Database Migration
- Created migration adding `has_payment_method`, `trial_end_date`, `standby` columns

### Phase 3: Free Plan & Billing Infrastructure
- Added `get_free_plan()` in `plans.rs`, included in purchasable and fixture plans
- Added `is_free()` and `host_limit()` helper methods to `BillingPlan`
- Exempted Free from billing middleware (alongside Community/CommercialSelfHosted/Demo)

### Phase 4: Backend Enforcement
- Host limit checked on manual creation (handlers.rs) and discovery creation (service.rs)
- Scheduled discovery restriction in create/update handlers
- DaemonPoll restriction in `process_registration()`
- Daemon standby: skip in poller, return `DaemonStandby` error in `receive_work_request`
- Daemon-side standby: detect error, log warning, block with `ctrl_c().await`

### Phase 5: Billing Service
- Trial without credit card: `payment_method_collection: IfRequired` for trial checkout
- Setup payment method endpoint (`POST /api/billing/setup-payment-method`)
- Change plan endpoint (`POST /api/billing/change-plan`) with upgrade/downgrade logic
- Plan change preview endpoint (`GET /api/billing/change-plan/preview`)
- `customer.subscription.trial_will_end` webhook handler
- `checkout.session.completed` handler for setup mode (marks `has_payment_method`)
- `downgrade_to_free()`: converts scheduled→adhoc, sets standby on DaemonPoll, trims hosts
- Store `trial_end_date` from subscription webhooks
- `handle_subscription_deleted` calls `downgrade_to_free()` instead of clearing plan
- Added `host_service`, `daemon_service`, `discovery_service` to `BillingServiceParams`

### Phase 6: Transactional Emails
- 6 billing email templates (trial started/ending/expired, payment added, plan changed, cancelled)
- `send_billing_email` trait method on `EmailProvider`
- Builder methods for each template
- Implemented in both Plunk and SMTP providers

### Phase 7: Frontend Changes
- Generated TypeScript types via `make generate-types`
- Added `scheduled_discovery` and `daemon_poll` to `BillingPlanMetadata` interface
- Added `BillingRate` type export
- New query hooks: `useSetupPaymentMethodMutation`, `useChangePlanMutation`, `useChangePlanPreviewQuery`
- Created `UpgradeBadge.svelte` component (dispatches `open-settings` event on click)
- `DiscoveryTypeForm.svelte`: Scheduled option disabled when feature unavailable, shows UpgradeBadge
- `CreateDaemonForm.svelte`: DaemonPoll option disabled when feature unavailable, shows UpgradeBadge
- `HostTab.svelte`: Host count indicator (`X / 25`), warning at limit, UpgradeBadge replaces create button at limit
- `Sidebar.svelte`: Amber notification dot on Settings when no payment method
- `BillingTab.svelte`: Host usage with progress bar, trial countdown, Add Payment Method CTA, Free plan upgrade prompt

### Phase 8: Fixtures & Tests
- All 114 backend unit tests pass (including `test_feature_ids_match_billing_plan_features_fields`)
- All 14 frontend tests pass
- Format and lint clean (0 errors, 0 warnings)
- Billing fixtures regenerated with Free plan and new features

### Phase 9: Onboarding Simplification
- Removed "Add another network" button from `OrgNetworksModal.svelte` — all use cases get exactly 1 network
- Removed daemon and daemon_verification steps from onboarding flow in `onboarding/+page.svelte`
- Step type narrowed to `use_case | blocker | setup | register` (always 3 steps)
- Set `sessionStorage('showDaemonSetup')` flag on registration completion
- Main app (`+page.svelte`) reads flag to land on daemons tab immediately after onboarding
- `DaemonTab.svelte` reads flag to auto-open CreateDaemonModal (flag cleared after read)
- CreateDaemonForm already has plan-based gating: DaemonPoll disabled with UpgradeBadge for Free plan
- Removed unused i18n keys (`onboarding_addAnotherNetwork`, `onboarding_removeNetwork`)
- Cleaned up dead code: `addNetwork`/`removeNetwork` functions, daemon imports, `hasIntegratedDaemon`, `daemonsInstalled` tracking

### Files Changed (key files)
**Backend:** `billing/types/base.rs`, `billing/types/features.rs`, `billing/types/api.rs`, `billing/plans.rs`, `billing/service.rs`, `billing/handlers.rs`, `shared/types/error_codes.rs`, `shared/storage/filter.rs`, `shared/services/factory.rs`, `auth/middleware/billing.rs`, `hosts/service.rs`, `hosts/handlers.rs`, `discovery/handlers.rs`, `daemons/service.rs`, `daemons/handlers.rs`, `daemons/impl/base.rs`, `daemon/runtime/service.rs`, `organizations/impl/base.rs`, `email/templates.rs`, `email/traits.rs`, `email/plunk.rs`, `email/smtp.rs`, migration file
**Frontend:** `stores/metadata.ts`, `billing/queries.ts`, `billing/types.ts`, `UpgradeBadge.svelte`, `BillingTab.svelte`, `DiscoveryTypeForm.svelte`, `CreateDaemonForm.svelte`, `HostTab.svelte`, `Sidebar.svelte`, `billing-plans-next.json`, `features-next.json`, `OrgNetworksModal.svelte`, `onboarding/+page.svelte`, `+page.svelte`, `DaemonTab.svelte`, `messages/en.json`
