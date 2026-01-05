# Task: Email Lifecycle Events & Plunk Research

> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

## Objective

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
- [ ] Linting passes: `make format && make lint`

## Important

**Report back after Phase 1 research** before deep implementation. The scope of Phase 2 depends on what Plunk supports.

---

## Research Findings

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
