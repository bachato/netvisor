> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Replace HubSpot with Brevo

## Objective

Replace HubSpot with Brevo as the consolidated CRM and non-transactional email platform. Brevo will handle: CRM (contacts, companies, deals/pipeline), event-driven marketing automation, and non-transactional email campaigns (onboarding sequences, lifecycle emails, cart recovery). Transactional emails (password reset, invite, verification) remain on Plunk/SMTP — they live in the app and don't need a marketing platform.

## Context

### Current HubSpot Integration

The HubSpot integration is in `backend/src/server/hubspot/` and consists of:

| File | Purpose |
|------|---------|
| `mod.rs` | Module exports |
| `types.rs` | Contact/Company property types, API request/response structs |
| `client.rs` | HubSpot API client with rate limiting (8 req/sec) and exponential backoff retries |
| `service.rs` | Event handling, business logic, org sync, metrics sync, startup backfill |
| `subscriber.rs` | EventBus subscriber (telemetry, auth, entity, discovery events), 5-sec debounce |
| `freemail.rs` | Work vs free email domain detection (4,500+ free domains, 88,000+ disposable) |
| `freemail_free.txt` | Free email domain list |
| `freemail_disposable.txt` | Disposable email domain list |

### What HubSpot Currently Syncs

**Contact properties:** email, firstname, lastname, jobtitle, scanopy_user_id, scanopy_org_id, scanopy_role, scanopy_signup_source, scanopy_use_case, scanopy_signup_date, scanopy_last_login_date, scanopy_marketing_opt_in

**Company properties:** name, scanopy_org_id, scanopy_org_type, scanopy_company_size, scanopy_plan_type, scanopy_plan_status, scanopy_mrr, scanopy_network_count, scanopy_host_count, scanopy_user_count, scanopy_network_limit, scanopy_seat_limit, scanopy_created_date, scanopy_last_discovery_date, scanopy_discovery_count, plus ~10 milestone dates (first_daemon, first_discovery, trial_started, checkout_completed, first_network, first_tag, first_api_key, first_snmp_credential, first_invite_sent, first_invite_accepted) and inquiry fields.

**Events subscribed to:**
- All telemetry operations (OrgCreated, CheckoutStarted, CheckoutCompleted, TrialStarted, TrialEnded, SubscriptionCancelled, FirstDaemonRegistered, FirstTopologyRebuild, FirstNetworkCreated, etc.)
- Auth: LoginSuccess (updates last_login_date)
- Entity CRUD: Network/Host/User create/delete (metrics sync)
- Discovery: Scanning phase (last_discovery_date)

**Filtering (REMOVING):** HubSpot currently only syncs orgs with commercial plans OR work email domains. **Brevo will sync ALL organizations** — no filtering. The `freemail.rs` filtering logic and `scanopy_non_commercial` flag are no longer needed for CRM sync. (Note: `freemail.rs` is also used for disposable email rejection at registration — check if it's imported elsewhere before removing.)

**Frontend:** `PlanInquiryModal.svelte` submits enterprise inquiries to HubSpot Forms API (portal 50956550, form 96ece46e-04cb-47fc-bb17-2a8b196f8986) and also updates CRM company properties via the backend.

### Factory Wiring

In `shared/services/factory.rs` (lines ~298-349):
- HubSpotService created if `config.hubspot_api_key` is set
- Injected with: NetworkService, HostService, UserService, OrganizationService, DaemonService, TagService, UserApiKeyService, SnmpCredentialService
- Registered as EventBus subscriber

### Database

`organizations.hubspot_company_id` column stores the HubSpot company ID after sync.

---

## Requirements

### 1. Create Brevo Module

Create `backend/src/server/brevo/` mirroring the HubSpot module structure:

| File | Purpose |
|------|---------|
| `mod.rs` | Module exports |
| `types.rs` | Brevo contact/company property types, API request/response structs |
| `client.rs` | Brevo API client with rate limiting and retries |
| `service.rs` | Event handling, business logic, sync, backfill |
| `subscriber.rs` | EventBus subscriber (same event patterns as HubSpot) |

### 2. Brevo API Client

Brevo REST API base: `https://api.brevo.com/v3`

**Key endpoints to implement:**

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create contact | `POST /contacts` | Upsert by email |
| Update contact | `PUT /contacts/{identifier}` | By email or ID |
| Search contact | `POST /contacts/search` | Filter by attributes |
| Create company | `POST /companies` | |
| Update company | `PATCH /companies/{id}` | |
| Search company | `POST /companies/search` | Filter by attributes |
| Link contact to company | `PATCH /companies/link-unlink/{id}` | Associate contact with company |
| Create deal | `POST /crm/deals` | For sales pipeline |
| Track event | `POST /events` | For automation triggers |

**Auth:** `api-key` header with Brevo API key.

**Rate limiting:** Brevo allows 300 requests/minute on most plans. Implement with `governor` crate following the HubSpot client pattern. Set to ~4 req/sec with burst.

**Retry:** Same exponential backoff pattern as HubSpot client — retry on 429 and 5xx.

**Important:** Research the exact Brevo API v3 endpoints, request/response formats, and authentication before implementing. The endpoints above are directional — verify against Brevo's current API docs.

### 3. Property Mapping

Map all existing HubSpot properties to Brevo contact/company attributes. Brevo uses "attributes" instead of "properties."

**Contact attributes** (map from HubSpot contact properties):
- Standard: `EMAIL`, `FIRSTNAME`, `LASTNAME`
- Custom: Create custom attributes for all `scanopy_*` fields (same names, Brevo supports custom attributes on contacts)

**Company attributes** (map from HubSpot company properties):
- `name` + all `scanopy_*` company properties as custom attributes

**Brevo attribute types:** text, number, boolean, date, category. Map appropriately (dates as date type, counts as number, flags as boolean).

### 4. Service Layer

Implement `BrevoService` with the same methods as `HubSpotService`:

| Method | Trigger | Behavior |
|--------|---------|----------|
| `handle_org_created` | OrgCreated | Create contact + company, store company ID |
| `handle_checkout_started` | CheckoutStarted | Update plan_status |
| `handle_checkout_completed` | CheckoutCompleted | Set plan type, status, date |
| `handle_trial_started` | TrialStarted | Set status to trialing |
| `handle_trial_ended` | TrialEnded | Set status based on conversion |
| `handle_subscription_cancelled` | SubscriptionCancelled | Set status |
| `handle_first_daemon_registered` | FirstDaemonRegistered | Record date |
| `handle_first_topology_rebuild` | FirstTopologyRebuild | Record date |
| `handle_engagement_event` | Various first-time events | Record milestone dates |
| `update_contact_last_login` | LoginSuccess | Update last_login_date |
| `update_company_last_discovery` | Scanning | Update last_discovery_date |
| `sync_org_entity_metrics` | Network/Host/User CRUD | Query DB, sync counts |
| `backfill_organizations` | Server startup | See section 6 below |

**No filtering:** Sync ALL organizations to Brevo. Remove the `should_sync_to_hubspot()` check and `scanopy_non_commercial` flag. Every org gets a Brevo contact + company.

### 5. Event Subscriber

Implement `EventSubscriber` for `BrevoService` with the same event filter and debounce behavior as HubSpot:
- Subscribe to: all telemetry, LoginSuccess, Network/Host/User CRUD, Discovery Scanning
- 5-second debounce window for batching
- Non-blocking error handling

Subscriber name: `brevo_crm`

### 6. Startup Backfill

On server startup, `BrevoService` must backfill all organizations that don't yet have a `brevo_company_id`:

1. Query all organizations where `brevo_company_id IS NULL`
2. For each: create contact (from org owner) + company in Brevo, store the returned company ID
3. Backfill telemetry milestones from database (same pattern as HubSpot's `sync_existing_organizations()`)
4. Sync current entity metrics (network count, host count, user count)
5. Rate-limit the backfill to avoid hitting Brevo API limits
6. Log progress: "Backfilling org {name} ({x}/{total})"
7. Non-blocking: errors on individual orgs should be logged and skipped, not halt the entire backfill

This runs on every server startup but is effectively a no-op once all orgs have brevo_company_ids.

### 7. Event Tracking for Automation

Brevo's event tracking (`POST /events`) allows triggering automation workflows. Track key events:

- `org_created` — trigger onboarding sequence
- `trial_started` — trigger trial nurture sequence
- `trial_ended` — trigger conversion/winback sequence
- `checkout_completed` — trigger welcome/success sequence
- `first_discovery_completed` — trigger engagement sequence
- `subscription_cancelled` — trigger winback sequence

Send via Brevo's event tracking API so they appear in Brevo's automation builder.

### 8. Enterprise Inquiry Form

**Backend:** Replace HubSpot form submission in `billing/handlers.rs` (`inquiry` endpoint, lines 216-313):
- Currently submits to HubSpot Forms API + updates CRM company
- Replace with: create/update Brevo contact with inquiry data + update Brevo company + optionally create a deal in Brevo's CRM pipeline

**Frontend:** Update `PlanInquiryModal.svelte`:
- Remove HubSpot tracking cookie (`hubspotutk`) extraction
- Remove HubSpot-specific form field mapping
- The modal continues to POST to `POST /api/billing/inquiry` — backend handles Brevo

### 9. Database Migration

```sql
ALTER TABLE organizations RENAME COLUMN hubspot_company_id TO brevo_company_id;
```

Update `StorableFilter` implementations that reference `hubspot_company_id`.

### 10. Configuration

**Replace env vars:**
- `SCANOPY_HUBSPOT_API_KEY` → `SCANOPY_BREVO_API_KEY`

**Update:**
- `ServerConfig` in `config.rs`: replace `hubspot_api_key` with `brevo_api_key`
- `factory.rs`: create `BrevoService` instead of `HubSpotService` when `brevo_api_key` is set
- `.env.example` if it references HubSpot

**Frontend config:**
- If `has_hubspot` or similar is exposed via `/config`, rename to `has_crm` or `has_brevo`
- Remove HubSpot tracking script loading (check for HubSpot script tags in frontend layout)
- Cookie consent: if tied to HubSpot, update for Brevo or remove if not needed for CRM-only

### 11. Remove HubSpot Module

After Brevo module is complete and tested:
- Delete `backend/src/server/hubspot/` directory entirely
- Remove from `mod.rs` parent module
- Remove `hubspot` from any feature flags, test configs, or CI references
- Clean up HubSpot-specific imports
- **`freemail.rs` and domain lists:** Check if `freemail.rs` / `is_work_email()` / disposable email detection is used outside of HubSpot (e.g., registration rejects disposable emails). If used elsewhere, move to `shared/`. If only used by HubSpot filtering, it can be deleted.

### 12. Frontend Cleanup

- `PlanInquiryModal.svelte` — remove HubSpot cookie/form logic, keep form UI and `POST /api/billing/inquiry`
- Check for HubSpot tracking script in layout files
- Remove `hubspot` references in frontend config types
- Update `/config` endpoint response type if field names changed

---

## Key Files

**Create:**
- `backend/src/server/brevo/mod.rs`
- `backend/src/server/brevo/types.rs`
- `backend/src/server/brevo/client.rs`
- `backend/src/server/brevo/service.rs`
- `backend/src/server/brevo/subscriber.rs`

**Modify:**
- `backend/src/server/shared/services/factory.rs` — wire BrevoService
- `backend/src/server/config.rs` — brevo_api_key
- `backend/src/server/billing/handlers.rs` — inquiry endpoint
- `backend/src/server/organizations/impl/base.rs` — brevo_company_id field
- `backend/migrations/` — rename column
- `ui/src/lib/features/billing/PlanInquiryModal.svelte` — remove HubSpot specifics
- Frontend layout/config — remove HubSpot tracking, update cookie consent

**Delete:**
- `backend/src/server/hubspot/` — entire module
- `freemail.rs` + domain lists IF not used outside HubSpot (check first)

---

## Acceptance Criteria

- [ ] Brevo module created with client, types, service, subscriber
- [ ] All HubSpot contact + company properties mapped to Brevo attributes
- [ ] EventBus subscriber handles all events HubSpot did (telemetry, auth, entity CRUD, discovery)
- [ ] ALL organizations synced (no commercial/work-email filtering)
- [ ] Startup backfill: all orgs without brevo_company_id get synced on server start
- [ ] Event tracking for automation triggers (org_created, trial_started, etc.)
- [ ] Enterprise inquiry form submits to Brevo instead of HubSpot
- [ ] Database: hubspot_company_id renamed to brevo_company_id
- [ ] Config: SCANOPY_BREVO_API_KEY replaces SCANOPY_HUBSPOT_API_KEY
- [ ] Factory: BrevoService registered as EventBus subscriber
- [ ] HubSpot module deleted, no references remain
- [ ] Frontend: HubSpot tracking/cookies removed, PlanInquiryModal updated
- [ ] freemail.rs: moved to shared/ if used elsewhere, or removed
- [ ] All backend tests pass (`cd backend && cargo test`)
- [ ] `make format && make lint` passes

---

## Notes

- **Merge order:** This branch merges AFTER the billing-overhaul branch. Rebase before merging if needed.
- Brevo API docs should be consulted for exact endpoint formats — the specs above are directional.
- Plunk/SMTP transactional emails are NOT affected by this change.

---

## Work Summary

### What was implemented
- Full replacement of HubSpot CRM integration with Brevo
- Created `backend/src/server/brevo/` module (client, types, service, subscriber)
- Database migration renaming `hubspot_company_id` → `brevo_company_id` with stale ID clearing
- Config: `SCANOPY_HUBSPOT_API_KEY` → `SCANOPY_BREVO_API_KEY`
- Factory wiring: BrevoService replaces HubSpotService, registered as EventBus subscriber
- Startup backfill: syncs all orgs without `brevo_company_id` on server start (non-blocking)
- Billing inquiry endpoint updated to use Brevo (deals + event tracking instead of HubSpot Forms)
- Frontend: removed HubSpot tracking script, cookie extraction, and references
- Deleted entire `backend/src/server/hubspot/` module (including freemail domain lists)
- All organizations synced (no more commercial-plan/work-email filtering)

### Files changed
- **Created:** `backend/src/server/brevo/{mod,client,types,service,subscriber}.rs`
- **Created:** `backend/migrations/20260205183207_rename_hubspot_to_brevo.sql`
- **Modified:** `backend/src/server/mod.rs`, `config.rs`, `auth/service.rs`, `billing/handlers.rs`
- **Modified:** `backend/src/server/organizations/impl/{base,storage}.rs`
- **Modified:** `backend/src/server/shared/{services/factory.rs,storage/filter.rs,events/types.rs,types/examples.rs}`
- **Modified:** `backend/src/bin/server.rs`
- **Modified:** `ui/src/lib/features/billing/PlanInquiryModal.svelte`, `ui/src/lib/shared/components/layout/AppShell.svelte`
- **Modified:** `ui/src/lib/features/auth/{stores/onboarding.ts,components/onboarding/UseCaseStep.svelte}`
- **Deleted:** `backend/src/server/hubspot/` (all files)

### Migration note
Migration clears all existing `brevo_company_id` values (formerly `hubspot_company_id`) so every org gets re-synced to Brevo on next startup.
