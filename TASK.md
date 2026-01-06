<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
# Task: Fix Trial Hiding Logic
=======
# Task: Daemon Creation - Use Existing API Key Option
>>>>>>> daemon-key-selection
=======
# Task: Pricing Table "Gimme Features" Research & Implementation
>>>>>>> pricing-features
=======
# Task: Email Lifecycle Events & Plunk Research
>>>>>>> email-lifecycle-events

> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

## Objective

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
Fix bug where trial offers are incorrectly hidden for users who haven't actually used a trial. Currently hides trial for any org with a `stripe_customer_id`, but should only hide for orgs that have actually had a subscription/trial.

## Root Cause

A `stripe_customer_id` is created when checkout is **initiated**, before subscription is activated. So a first-time buyer already has a customer ID but hasn't used their trial yet.

## The Fix

Check `plan_status.is_some()` instead of `stripe_customer_id.is_some()`.

If `plan_status` has any value (trialing, active, past_due, canceled, etc.), the user has had a subscription and shouldn't get another trial.

## Requirements

1. **Backend:** Update `is_returning_customer` check in billing service
2. **Frontend:** Update `isReturningCustomer` derivation in billing page
3. No database migration needed

## Acceptance Criteria

- [ ] User with `stripe_customer_id` but no `plan_status` sees trial offers
- [ ] User with any `plan_status` value does NOT see trial offers
- [ ] Backend checkout correctly applies/skips trial based on `plan_status`
- [ ] Tests pass: `cd backend && cargo test` and `cd ui && npm test`
=======
Allow users creating a daemon from within the app (NOT during onboarding) to choose between generating a new API key or using an existing one. If using existing, provide an input field to paste the key.

## Requirements

1. Add toggle/choice: "Generate new key" vs "Use existing key"
2. If "Use existing key" selected, show text input for pasting key
3. Pasted key populates the binary run command and docker compose output
4. **Only in app** (CreateDaemonModal), NOT during onboarding (MultiDaemonSetup)

## Context

**App flow (CreateDaemonModal):** User is in the Daemons tab, clicks "Create Daemon"
- This is where the new option should appear

**Onboarding flow (MultiDaemonSetup):** User is registering, setting up first daemons
- Do NOT add the option here - keep existing "Install Now" / "Install Later" flow

## Acceptance Criteria

- [ ] CreateDaemonModal has option to use existing key
- [ ] Text input appears when "Use existing key" selected
- [ ] Pasted key flows through to run command and docker compose
- [ ] Validation: key format looks reasonable (non-empty at minimum)
- [ ] MultiDaemonSetup unchanged (onboarding flow)
- [ ] Tests pass: `cd ui && npm test`
>>>>>>> daemon-key-selection
- [ ] Linting passes: `make format && make lint`

## Files to Modify

<<<<<<< HEAD
### Backend

**File:** `backend/src/server/billing/service.rs`

Find (around line 326-340):
```rust
let is_returning_customer = if let Some(organization) = self
    .organization_service
    .get_by_id(&organization_id)
    .await?
{
    Ok(organization.base.stripe_customer_id.is_some())
} else {
    ...
}?;
```

Change to:
```rust
let is_returning_customer = if let Some(organization) = self
    .organization_service
    .get_by_id(&organization_id)
    .await?
{
    Ok(organization.base.plan_status.is_some())
} else {
    ...
}?;
```

### Frontend

**File:** `ui/src/routes/billing/+page.svelte`

Find (around line 25-26):
```typescript
// Returning customers (have existing Stripe customer ID) shouldn't see trial offers
let isReturningCustomer = $derived(!!organization?.stripe_customer_id);
```

Change to:
```typescript
// Returning customers (have had a subscription) shouldn't see trial offers
let isReturningCustomer = $derived(!!organization?.plan_status);
```

## Testing

1. **New user (no stripe_customer_id, no plan_status):** Should see trial offers
2. **User who started checkout but didn't complete (has stripe_customer_id, no plan_status):** Should see trial offers
3. **User with active subscription (has plan_status: "active"):** Should NOT see trial offers
4. **User with canceled subscription (has plan_status: "canceled"):** Should NOT see trial offers
5. **User currently in trial (has plan_status: "trialing"):** Should NOT see trial offers

## Notes

- The `plan_status` field reflects Stripe subscription status
- Values: "trialing", "active", "past_due", "canceled", "incomplete"
- An empty/null `plan_status` means they've never had a subscription
=======
### Primary

**File:** `ui/src/lib/features/daemons/components/CreateDaemonModal.svelte`

Current flow:
1. User fills daemon form
2. Clicks "Generate Key" button
3. `handleCreateNewApiKey()` creates key via API
4. Key stored in `keyState`, passed to `CreateDaemonForm`

New flow:
1. User fills daemon form
2. **New:** Chooses "Generate new key" or "Use existing key"
3. If generate: existing flow (API call)
4. If existing: show input field, user pastes key
5. Either way, key passed to `CreateDaemonForm`

### Secondary

**File:** `ui/src/lib/features/daemons/components/CreateDaemonForm.svelte`

May need minor updates if key handling changes, but likely no changes needed - it already accepts `apiKey` prop.

## UI Suggestions

Option 1 - Radio buttons:
```
( ) Generate new API key
( ) Use existing API key
    [_________________________] <- input appears when selected
```

Option 2 - Tabs or segmented control:
```
[Generate New] [Use Existing]
```

Option 3 - Secondary action:
```
[Generate Key]  or  [Use Existing Key]
```

Pick whichever fits the existing UI patterns best. Check other modals/forms for consistency.

## Implementation Notes

1. **Key state:** Currently `keyState` is populated by API response. For pasted keys, set it directly from input value.

2. **Validation:** At minimum, check the pasted key is non-empty. Optionally check format (prefix, length) if there's a known pattern.

3. **No backend changes:** The key is just passed to the command/compose generation - no API calls needed for "use existing" flow.

4. **Distinguish from onboarding:** The modal already knows it's not in onboarding mode. Check how `onboardingMode` prop is used if needed.

## Reference

Look at `CreateDaemonForm.svelte` lines 131-253 to see how keys are used in command generation:
- `buildRunCommand()` - includes `--daemon-api-key ${key}`
- `buildDockerCompose()` - includes `SCANOPY_DAEMON_API_KEY` env var
>>>>>>> daemon-key-selection
=======
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
>>>>>>> arp-redesign

---

## Work Summary

<<<<<<< HEAD
<<<<<<< HEAD
### Changes Made

**Backend** (`backend/src/server/billing/service.rs:326-332`):
- Changed `is_returning_customer` check from `stripe_customer_id.is_some()` to `plan_status.is_some()`
- Updated comment to reflect the new logic

**Frontend** (`ui/src/routes/billing/+page.svelte:25-26`):
- Changed `isReturningCustomer` derivation from `!!organization?.stripe_customer_id` to `!!organization?.plan_status`
- Updated comment to reflect the new logic

### Verification

- [x] Backend tests pass (79 passed, 2 ignored)
- [x] Frontend has no test script configured
- [x] Backend format (`cargo fmt`) and lint (`cargo clippy`) pass
- [x] Frontend format (`prettier`) and lint (`eslint`) pass

### Acceptance Criteria Status

- [x] User with `stripe_customer_id` but no `plan_status` sees trial offers
- [x] User with any `plan_status` value does NOT see trial offers
- [x] Backend checkout correctly applies/skips trial based on `plan_status`
- [x] Tests pass
- [x] Linting passes
=======
### What was implemented

Added the ability for users to choose between generating a new API key or using an existing one when creating a daemon from within the app (CreateDaemonModal).

**Changes to `ui/src/lib/features/daemons/components/CreateDaemonModal.svelte`:**

1. **New state variables:**
   - `keySource`: Tracks whether user selected 'generate' or 'existing'
   - `existingKeyInput`: Stores the pasted API key value

2. **New handlers:**
   - `handleKeySourceChange()`: Resets key state when switching between options
   - `handleUseExistingKey()`: Validates form and sets the pasted key

3. **Updated `handleOnClose()`:** Resets new state variables when modal closes

4. **Updated UI (lines 169-256):**
   - Radio button selection: "Generate new API key" / "Use existing API key"
   - Conditional rendering based on selection:
     - Generate: Existing flow (Generate Key button + CodeContainer)
     - Existing: Text input + "Use Key" button
   - Radio buttons disabled once a key is set (to prevent switching after key is in use)
   - Shows the entered key in CodeContainer after submission

### Files changed
- `ui/src/lib/features/daemons/components/CreateDaemonModal.svelte`

### No changes to
- `CreateDaemonForm.svelte` (already accepts `apiKey` prop correctly)
- `MultiDaemonSetup.svelte` (onboarding flow unchanged as required)

### Validation
- Form validation runs before key is accepted (same pattern as generate flow)
- Empty key input shows error via `pushError()`
- Key must be non-empty after trim

### Testing
- `make format` - passed
- `make lint` - passed (includes svelte-check with 0 errors)
>>>>>>> daemon-key-selection
=======
Research how successful SaaS companies position "value reinforcement" features in pricing tables, then propose and implement features that highlight Scanopy's value—even if they're included in all plans.

## Context

Many SaaS pricing pages list features that are the same across all plans to reinforce value. Examples:
- "Unlimited Scans"
- "Docker Integration"
- "Real-time Updates"
- "Secure by Default"

These aren't differentiators between plans, but they help users understand what they're getting and justify the price.

## Approach

**Phase 1: Research** (report findings before implementing)
- Study 5-10 SaaS pricing pages (network monitoring, DevOps, infrastructure tools)
- Identify patterns for "included in all plans" features
- Note what resonates for Scanopy's use case

**Phase 2: Propose**
- List 5-10 candidate features for Scanopy
- Recommend which to add and how to display them

**Phase 3: Implement**
- Add features to backend definitions
- Update frontend pricing table display
- Regenerate website fixtures

## Research Targets

Look at pricing pages for:
- Network/infrastructure monitoring: Datadog, New Relic, Zabbix, PRTG, Auvik
- DevOps/scanning tools: Snyk, Qualys, Tenable
- Similar indie/SMB tools: Tailscale, Netdata, Uptime Kuma (if commercial)

Questions to answer:
1. What "universal features" do they highlight?
2. How are they displayed (checkmarks, badges, separate section)?
3. What categories do they use?
4. What language/phrasing works well?

## Current Feature System

### Backend Definitions

**Features enum:** `backend/src/server/billing/types/features.rs`
```rust
pub enum Feature {
    ShareViews,
    RemoveCreatedWith,
    AuditLogs,
    Webhooks,
    ApiAccess,
    // ... etc
}
```

Each feature has:
- ID (snake_case string)
- Name (human readable)
- Description
- Category (Support, Licensing, Enterprise, Integrations, Sharing)
- Coming soon flag

**Plan features:** `backend/src/server/billing/types/base.rs`
```rust
pub struct BillingPlanFeatures {
    pub share_views: bool,
    pub webhooks: bool,
    pub api_access: bool,
    // ... etc
}
```

**Plan definitions:** `backend/src/server/billing/plans.rs`
- `get_default_plans()` - SaaS plans
- `get_website_fixture_plans()` - All plans for website

### Frontend Display

**Component:** `ui/src/lib/features/billing/BillingPlanForm.svelte`
- Displays plans in grid
- Shows features by category (collapsible sections)
- Checkmarks for included features

### Fixtures

**Generated files:** `ui/static/billing-plans.json`, `ui/static/features-next.json`
**Generator:** `backend/tests/integration/fixtures.rs` → `generate_billing_plans_json()`

These fixtures are used by the marketing website.

## Implementation Notes

### Adding a New Universal Feature

1. **Add to Feature enum** (`features.rs`):
```rust
UnlimitedScans, // or whatever
```

2. **Implement TypeMetadataProvider** for it:
```rust
Feature::UnlimitedScans => TypeMetadata {
    id: "unlimited_scans",
    name: "Unlimited Scans",
    description: "No limits on network discovery scans",
    category: Some("Core"), // may need new category
    coming_soon: false,
}
```

3. **Add to BillingPlanFeatures struct** (`base.rs`):
```rust
pub unlimited_scans: bool,
```

4. **Set to true for all plans** in `features()` method

5. **Regenerate fixtures**:
```bash
cd backend && cargo test generate_billing_plans_json -- --ignored
```

### Display Considerations

- May want a separate "Included in all plans" section vs per-plan checkmarks
- Could use badges/pills instead of checkmarks for universal features
- Consider a "Core Features" category that appears first

## Deliverables

1. **Research summary** in this file (Phase 1)
2. **Feature proposal** with recommendations (Phase 2)
3. **Implementation** with tests passing (Phase 3)
4. **Regenerated fixtures** committed

## Acceptance Criteria

- [ ] Research documented with examples from 5+ competitors
- [ ] 5-10 features proposed with rationale
- [ ] Features implemented in backend (Feature enum, BillingPlanFeatures)
- [ ] Frontend displays new features appropriately
- [ ] Fixtures regenerated (`ui/static/billing-plans.json`, `ui/static/features-next.json`)
- [ ] Tests pass: `cd backend && cargo test` and `cd ui && npm test`
=======
Research Plunk email automation capabilities, then implement backend events needed to support key automations like cart abandonment and customer recovery.

## Approach

**Phase 1: Research** (do this first, report findings before deep implementation)
- Understand Plunk automation/trigger capabilities
- Identify what events/data Plunk needs for automations
- Document findings in this file

**Phase 2: Implement**
- Add lifecycle events that enable the desired automations
- Ensure proper user/org data is tracked with events

## Target Automations

1. **Cart Abandonment:** User registers, gets to billing screen, doesn't complete purchase
2. **Customer Recovery:** Trial or subscription cancelled - win-back campaigns
3. **Onboarding Nudges:** User stalls at various onboarding steps

## Research Tasks

### 1. Plunk Documentation Review

Research: https://next-wiki.useplunk.com/

Answer these questions:
- What triggers/automations does Plunk support?
- Can automations be triggered by events? By time delays? By user properties?
- What event data format does Plunk expect?
- Can Plunk segment users by properties (plan type, trial status, etc.)?
- What's needed for cart abandonment flows specifically?

### 2. Current Implementation Review

**Plunk integration:** `backend/src/server/email/plunk.rs`
- Currently tracks events via `POST /v1/track` with `{ event, email }`
- Has `identify` capability? Check the API.

**Email subscriber:** `backend/src/server/email/subscriber.rs`
- Currently tracks all auth operations for authenticated users
- Converts operation name to lowercase string

**Billing events:** `backend/src/server/billing/service.rs`
- Stripe webhook handling
- Subscription lifecycle (create, update, delete)

## Events to Consider

Based on target automations, these events may be needed:

| Event | Trigger Point | Data Needed |
|-------|---------------|-------------|
| `user_registered` | Registration complete | email, org_id |
| `billing_page_viewed` | Visit /billing | email, org_id, current_plan |
| `checkout_started` | Checkout session created | email, plan_selected |
| `checkout_completed` | Subscription created | email, plan, trial_days |
| `checkout_abandoned` | ??? (time-based?) | email, plan_attempted |
| `trial_started` | Subscription status = trialing | email, plan, trial_end_date |
| `trial_ending_soon` | X days before trial end | email, plan, days_remaining |
| `trial_ended` | Trial period complete | email, plan, converted (bool) |
| `subscription_cancelled` | Cancellation processed | email, plan, reason? |

## Files Likely Involved

**Email:**
- `backend/src/server/email/plunk.rs` - Plunk API integration
- `backend/src/server/email/subscriber.rs` - Event subscription
- `backend/src/server/email/traits.rs` - EmailProvider trait

**Billing:**
- `backend/src/server/billing/service.rs` - Stripe integration, checkout
- `backend/src/server/billing/handlers.rs` - Webhook handlers

**Events:**
- `backend/src/server/shared/events/types.rs` - Event type definitions
- `backend/src/server/shared/events/bus.rs` - Event publishing

## Acceptance Criteria

- [ ] Plunk capabilities documented in this file
- [ ] Event implementation plan based on research
- [ ] Key lifecycle events implemented (based on findings)
- [ ] Events include necessary user/org properties for segmentation
- [ ] Tests pass: `cd backend && cargo test`
>>>>>>> email-lifecycle-events
- [ ] Linting passes: `make format && make lint`

## Important

<<<<<<< HEAD
**Report back after Phase 1 & 2** (research + proposal) before implementing. The specific features to add should be reviewed before coding.
=======
**Report back after Phase 1 research** before deep implementation. The scope of Phase 2 depends on what Plunk supports.
>>>>>>> email-lifecycle-events

---

## Research Findings

<<<<<<< HEAD
### Competitors Analyzed (8)

| Company | Category | Notable Universal Features |
|---------|----------|---------------------------|
| **Datadog** | Monitoring | 1,000+ integrations, unlimited alerting, out-of-box dashboards |
| **New Relic** | Monitoring | 750+ integrations, unlimited hosts/agents/containers, 100GB free data |
| **Snyk** | Security | IDE plugins, data encryption (transit + rest), SOC 2/GDPR/ISO compliance |
| **Tailscale** | Networking | End-to-end encryption (WireGuard), UI/CLI/API access, IPv4 & IPv6 |
| **Netdata** | Monitoring | Unlimited metrics, customizable charts |
| **Auvik** | Network mgmt | Unlimited users, unlimited sites, out-of-box alerts, no maintenance fees |
| **Tenable** | Security | Continuous discovery, fully documented API, real-time visualization |
| **Grafana** | Observability | 100+ pre-built solutions, 20+ data source plugins |

### Key Patterns Identified

**1. "Unlimited" Language**
Most competitors emphasize unlimited quantities for core functionality:
- Unlimited users/seats (Auvik, New Relic)
- Unlimited hosts/agents/containers (New Relic)
- Unlimited integrations/metrics (Datadog, Netdata)

**2. Integration/Ecosystem Numbers**
Specific counts reinforce breadth of value:
- "1,000+ integrations" (Datadog)
- "750+ integrations" (New Relic)
- "200+ service definitions" (Scanopy already has this!)

**3. Security as Baseline**
Security features positioned as universal, not premium:
- Data encryption in transit and at rest (Snyk)
- End-to-end encryption (Tailscale)
- SOC 2/GDPR compliance certifications (Snyk)

**4. "Always-on" / Real-time**
Continuous operation emphasized:
- "Continuous, always-on discovery" (Tenable)
- "Real-time visualization" (Tenable)
- Peer-to-peer connections (Tailscale)

**5. API Access as Value**
Programmatic access highlighted universally:
- "UI, CLI, and API access" (Tailscale)
- "Fully documented API and pre-built integrations" (Tenable)

**6. Pre-built / Out-of-box**
Instant value without configuration:
- "Out-of-the-box dashboards" (Datadog)
- "Out-of-box alerts" (Auvik)
- "100+ pre-built solutions" (Grafana)

### Display Methods Observed

| Method | Used By | Description |
|--------|---------|-------------|
| Checkmark tables | Datadog, Snyk | Traditional feature grid |
| "All plans include" section | Auvik | Separate callout box |
| Inline statements | New Relic | "Unlimited X at no extra cost" |
| Category headers | Tailscale, Snyk | Group features logically |

### Language That Resonates for Scanopy's Use Case

- "Automatic discovery" - core value prop
- "Zero maintenance" / "one-time setup"
- "200+ service definitions" - already a differentiator
- "Docker integration" - DevOps appeal
- "Real-time updates" - live topology
- "Self-hosted option" - privacy/control

## Feature Proposal

### Recommended Universal Features (8)

These features are true for all plans and reinforce Scanopy's core value:

| # | Feature ID | Display Name | Description | Rationale |
|---|------------|--------------|-------------|-----------|
| 1 | `unlimited_scans` | Unlimited Scans | No limits on network discovery scans | Mirrors "unlimited" language from Auvik/New Relic |
| 2 | `unlimited_hosts` | Unlimited Hosts | Monitor as many hosts as your network has | New Relic pattern - removes anxiety about scaling |
| 3 | `service_definitions` | 200+ Service Definitions | Auto-detect databases, containers, web servers, and more | Already a key differentiator - make it visible |
| 4 | `docker_integration` | Docker Integration | Automatic discovery of containerized services | DevOps appeal, mentioned in README |
| 5 | `real_time_updates` | Real-time Updates | Live topology updates as your network changes | Tenable pattern - "always-on" value |
| 6 | `data_encryption` | Data Encryption | All data encrypted in transit and at rest | Security baseline per Snyk pattern |
| 7 | `ipv4_ipv6` | IPv4 & IPv6 Support | Full support for modern dual-stack networks | Tailscale pattern - network feature |
| 8 | `self_hosted` | Self-hosted Available | Deploy on your own infrastructure | Privacy/control differentiator |

### Proposed Category

Create a new **"Core"** category that displays first, before plan differentiators.

### Display Recommendation

Option A (Preferred): **"Included in all plans" callout section** at top of pricing table, using badge/pill style rather than checkmarks. This follows the Auvik pattern and draws attention to universal value.

Option B: Add to feature grid with checkmarks, but group under "Core" category that appears first.

### Features NOT Recommended

| Feature | Reason |
|---------|--------|
| Open Source / AGPL | Licensing messaging is complex; could confuse pricing |
| Multi-user support | Already exists as org management - don't duplicate |
| Scheduled discovery | Already a core feature - not a "gimme" |

### Implementation Impact

- **New Category:** "Core" - appears first in feature list
- **5 new Feature enum variants** in `features.rs`
- **5 new fields** in `BillingPlanFeatures` (all set to `true`)
- **Frontend:** May need styling for "all plans" badge treatment

## Work Summary

### Implemented

Added 5 new "Core" features that are included in all plans:

| Feature ID | Display Name | Description |
|------------|--------------|-------------|
| `unlimited_scans` | Unlimited Scans | No limits on network discovery scans |
| `unlimited_hosts` | Unlimited Hosts | Monitor as many hosts as your network has |
| `service_definitions` | 200+ Service Definitions | Auto-detect databases, containers, web servers, and more |
| `docker_integration` | Docker Integration | Automatic discovery of containerized services |
| `real_time_updates` | Real-time Updates | Live topology updates as your network changes |

### Files Changed

**Backend:**
- `backend/src/server/billing/types/features.rs` - Added 5 Feature enum variants, HasId, category, name, description implementations
- `backend/src/server/billing/types/base.rs` - Added 5 fields to BillingPlanFeatures, set all to `true` for all 8 plan types, updated Into<Vec<Feature>> impl

**Frontend Fixtures:**
- `ui/static/features.json` - Added 5 new feature definitions under "Core" category
- `ui/static/billing-plans.json` - Added 5 new feature fields (all true) to all 14 plan entries

### Deviations from Proposal

3 features were removed at user request:
- `self_hosted` - Skipped
- `ipv4_ipv6` - Skipped
- `data_encryption` - Skipped

### Verification

- `cargo test --lib` - 79 passed, 2 ignored
- `cargo test feature_ids` - Verifies Feature IDs match BillingPlanFeatures fields
- `make format && make lint` - All pass
>>>>>>> pricing-features
=======
### Plunk API Capabilities

**Track Event Endpoint:** `POST /v1/track`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Event name to track |
| `email` | string | Yes | Contact email address |
| `subscribed` | boolean | No | Auto-subscribe contact (default: true) |
| `data` | object | No | **Metadata to attach to contact for segmentation** |

**Key Insight:** The `data` field persists on the contact record and enables segmentation.

**Automation Features:**
- Visual workflow builder with triggers, delays, and conditional logic
- Dynamic segments based on contact data and behavior
- Event-triggered workflows

### Current Implementation Gap

`plunk.rs:96-100` sends only `{ event, email }` — missing the `data` field needed for segmentation.

### Cart Abandonment Strategy (Approach 1: Segment-Based)

Use contact metadata to track checkout state, enabling Plunk to segment and automate:

```
Backend Events:
1. checkout_started  → data: { checkout_status: "pending", plan_name, is_commercial }
2. checkout_completed → data: { checkout_status: "completed", plan_name, has_trial }

Plunk Workflow Configuration:
- Trigger: checkout_started event
- Delay: 24 hours
- Condition: checkout_status == "pending"
- Action: Send cart abandonment email
```

This works because `checkout_completed` updates `checkout_status` to "completed", so the condition fails and no email is sent.

### Implementation Plan

**1. Enhance `track_event` signature:**
```rust
async fn track_event(
    &self,
    event: String,
    email: EmailAddress,
    data: Option<serde_json::Value>  // NEW
) -> Result<(), Error>
```

**2. Events to implement:**

| Event | Trigger Point | Data |
|-------|---------------|------|
| `checkout_started` | `create_checkout_session()` | `{ checkout_status: "pending", plan_name, is_commercial, org_id }` |
| `checkout_completed` | Subscription created webhook | `{ checkout_status: "completed", plan_name, has_trial, org_id }` |
| `trial_started` | Subscription status = trialing | `{ trial_status: "active", plan_name, trial_end_date, org_id }` |
| `trial_ended` | Subscription status change from trialing | `{ trial_status: "ended", converted: bool, org_id }` |
| `subscription_cancelled` | Subscription deleted webhook | `{ subscription_status: "cancelled", plan_name, org_id }` |

**3. Files to modify:**
- `backend/src/server/email/plunk.rs` — Add `data` parameter to `track_event`
- `backend/src/server/email/traits.rs` — Update `EmailProvider` trait
- `backend/src/server/email/subscriber.rs` — Pass `None` for existing calls
- `backend/src/server/billing/service.rs` — Add event tracking calls

**4. Plunk Workflow Configurations (to be set up in Plunk UI):**

| Automation | Trigger | Delay | Condition | Action |
|------------|---------|-------|-----------|--------|
| Cart Abandonment | `checkout_started` | 24h | `checkout_status == "pending"` | Send abandonment email |
| Trial Ending | `trial_started` | (trial_days - 3) days | `trial_status == "active"` | Send trial ending reminder |
| Win-Back | `subscription_cancelled` | 7 days | `subscription_status == "cancelled"` | Send win-back email |

## Work Summary

### Files Modified

| File | Changes |
|------|---------|
| `backend/src/server/email/traits.rs` | Added `data: Option<Value>` parameter to `track_event` trait method and `EmailService` wrapper |
| `backend/src/server/email/plunk.rs` | Updated `track_event` to include `data` field in Plunk API request body |
| `backend/src/server/email/subscriber.rs` | Added billing lifecycle event handling with metadata passthrough |
| `backend/src/server/shared/events/types.rs` | Added 5 new `TelemetryOperation` variants: `CheckoutStarted`, `CheckoutCompleted`, `TrialStarted`, `TrialEnded`, `SubscriptionCancelled` |
| `backend/src/server/billing/service.rs` | Added event publishing for all billing lifecycle events |

### Implementation Details

**Event-Driven Architecture:** Used existing `EventBus` pattern instead of direct email service coupling. Billing service publishes `TelemetryEvent` instances, and the email subscriber handles them.

**Events Published:**

| Event | Trigger | Key Metadata |
|-------|---------|--------------|
| `checkout_started` | `create_checkout_session()` | `checkout_status: "pending"`, plan info |
| `checkout_completed` | First subscription webhook | `checkout_status: "completed"`, plan info |
| `trial_started` | Subscription status = trialing | `trial_status: "active"`, trial end date |
| `trial_ended` | Trial→Active or Trial→Cancelled | `trial_status: "ended"`, `converted: bool` |
| `subscription_cancelled` | Subscription deleted webhook | `subscription_status: "cancelled"`, plan info |

### Testing

- `cargo test` - All tests pass
- `cargo fmt && cargo clippy` - No warnings

### Plunk Workflow Configuration (Next Step)

Configure in Plunk UI:

| Automation | Trigger | Delay | Condition | Action |
|------------|---------|-------|-----------|--------|
| Cart Abandonment | `checkout_started` | 24h | `checkout_status == "pending"` | Send abandonment email |
| Trial Ending | `trial_started` | (trial_days - 3) days | `trial_status == "active"` | Send trial ending reminder |
| Win-Back | `subscription_cancelled` | 7 days | `subscription_status == "cancelled"` | Send win-back email |
>>>>>>> email-lifecycle-events
=======
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
>>>>>>> arp-redesign
