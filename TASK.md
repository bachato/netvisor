> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**.

# Task: Generic Modal Deep-Link System

## Objective

Implement bidirectional URL ↔ modal state synchronization so that any modal can be opened via URL parameters, and opening a modal manually updates the URL. This replaces scattered one-off patterns (`?auth_modal`, `sessionStorage.showDaemonSetup`, `showBillingPlanModal` store) with a single generic system.

## Requirements

### 1. Add `name` prop to GenericModal

**File:** `ui/src/lib/shared/components/layout/GenericModal.svelte`

- Add optional `name?: string` prop — the deep-link identifier for this modal
- Add optional `entityId?: string` prop — for entity-specific modals
- When a modal with `name` opens:
  - Update URL: `?modal=<name>` (plus `&id=<entityId>` if present, `&tab=<tabId>` if tabs active)
  - Use `history.replaceState` to avoid polluting browser history
- When a modal with `name` closes:
  - Remove `modal`, `id`, `tab` params from URL via `replaceState`
- When URL already has `?modal=<name>` on mount/change:
  - Trigger the modal to open (set `isOpen = true`)
  - If `&tab=<tabId>` present, set `activeTab`

### 2. Create Modal Registry Store

**File:** `ui/src/lib/shared/stores/modal-registry.ts` (new)

- Central store mapping modal names → open/close/setTab callbacks
- GenericModal registers on mount (if `name` provided), unregisters on destroy
- Provide `openModal(name, opts?: { id?, tab? })` function for programmatic use
- Provide `closeModal(name)` function
- URL watcher: on `$page.url` change, if `?modal=` is present, call appropriate registry entry

### 3. Add `name` to key modal instances

Add `name` prop to these GenericModal call sites:

| Modal | `name` value | Has tabs? | Entity-specific? |
|-------|-------------|-----------|------------------|
| BillingPlanModal | `billing-plan` | No | No |
| SettingsModal | `settings` | Yes (`account`, `organization`, `billing`) | No |
| SupportModal | `support` | No | No |
| CreateDaemonModal | `create-daemon` | No | No |
| HostEditor | `host-editor` | Yes (7 tabs) | Yes (`host.id`) |
| NetworkEditModal | `network-editor` | No | Yes |
| TagEditModal | `tag-editor` | No | Yes |
| GroupEditModal | `group-editor` | Yes (3 tabs) | Yes |
| ServiceEditModal | `service-editor` | No | Yes |
| DiscoveryEditModal | `discovery-editor` | No | Yes |
| ShareModal | `share-editor` | No | Yes |
| UserEditModal | `user-editor` | No | Yes |
| UserApiKeyModal | `user-api-key` | No | Yes |

Entity-specific modals: the parent component (e.g., HostTab) needs to watch for `?modal=host-editor&id=<uuid>` and handle fetching the entity + opening the modal. Add a small reactive block in each parent tab that reads from the modal registry or URL.

### 4. Deprecate existing one-off triggers

| Current Pattern | Location | Replace With |
|----------------|----------|-------------|
| `?auth_modal` → opens settings | `Sidebar.svelte` onMount | `?modal=settings` (handled generically) |
| `sessionStorage.showDaemonSetup` | `DaemonTab.svelte`, `onboarding/+page.svelte`, `+page.svelte` | Set `?modal=create-daemon` in URL during redirect |
| `showBillingPlanModal` store | `billing/stores.ts`, used in 6+ files | `openModal('billing-plan')` from registry. Keep store as thin wrapper initially if needed for backwards compat, but it should delegate to the registry |
| `reopenSettingsAfterBilling` store | `Sidebar.svelte`, `BillingTab.svelte` | After Stripe return, set `?modal=settings&tab=billing` |
| Past due → forced settings | `+page.svelte` | `openModal('settings', { tab: 'billing' })` with non-dismissible flag |

### 5. Keep as-is (do NOT change)

- `?billing_flow=checkout/payment_setup` — Stripe callback, not a modal trigger
- `?error` — OIDC error toast
- `?token` — auth redirect
- `ConfirmationDialog`, `PasswordGate`, `LoginModal`, `RegisterModal` — don't need deep-linking

## Edge Cases

- If user is not authenticated, modal params stay in URL. After login redirect, the effect should pick them up.
- Multiple modals: only one `?modal=` at a time (last one wins). Nested modals (e.g., PlanInquiryModal inside BillingPlanModal) don't get URL params.
- Entity-specific without ID in URL: `?modal=host-editor` without `&id=` should open create mode.
- Tab param without modal: `?tab=billing` alone does nothing — requires `?modal=settings`.

## Files Likely Involved

- `ui/src/lib/shared/components/layout/GenericModal.svelte` — core changes
- `ui/src/lib/shared/stores/modal-registry.ts` — new file
- `ui/src/lib/shared/components/layout/Sidebar.svelte` — deprecate `?auth_modal`, `reopenSettingsAfterBilling`
- `ui/src/lib/shared/components/layout/AppShell.svelte` — may need URL watcher integration
- `ui/src/lib/features/billing/stores.ts` — deprecate/thin-wrap `showBillingPlanModal`
- `ui/src/lib/shared/components/UpgradeButton.svelte` — use registry instead of store
- `ui/src/lib/features/settings/BillingTab.svelte` — use registry
- `ui/src/lib/features/daemons/components/DaemonTab.svelte` — deprecate sessionStorage
- `ui/src/lib/features/daemons/components/CreateDaemonForm.svelte` — use registry
- `ui/src/lib/features/discovery/components/DiscoveryModal/DiscoveryTypeForm.svelte` — use registry
- `ui/src/routes/+page.svelte` — deprecate sessionStorage, past-due logic
- `ui/src/routes/onboarding/+page.svelte` — use URL param instead of sessionStorage
- All 13+ modal wrapper files listed above — add `name` prop

## Acceptance Criteria

- [ ] `?modal=billing-plan` opens billing plan modal from any page
- [ ] `?modal=settings&tab=billing` opens settings modal on billing tab
- [ ] `?modal=host-editor&id=<uuid>&tab=services` opens host editor for that host on services tab
- [ ] Opening a modal manually (button click) updates the URL to include `?modal=...`
- [ ] Closing a modal removes modal params from URL
- [ ] All 5 deprecated triggers replaced and working via the new system
- [ ] `sessionStorage.showDaemonSetup` fully removed
- [ ] No regressions in existing modal flows (Stripe return, past-due billing, onboarding → daemon)
- [ ] `cd ui && npm run check` passes
- [ ] `make format && make lint` passes

---

## Work Summary

### What was implemented

A generic modal deep-link system that replaces scattered one-off patterns with a single `?modal=<name>&id=<id>&tab=<tab>` URL-driven approach.

### Core infrastructure (2 new/modified files)

- **`ui/src/lib/shared/stores/modal-registry.ts`** (NEW): Central store with `modalState`, `openModal()`, `closeModal()`, `setModalTab()`, `initModalFromUrl()`. Uses `history.replaceState` for URL sync.
- **`ui/src/lib/shared/components/layout/GenericModal.svelte`**: Added `name` and `entityId` props. On open transition, syncs to URL via `openModal()`. On close, calls `closeModal()`. On tab click, calls `setModalTab()`.

### Modal wrappers updated (18 files)

All 18 modal wrappers received `name?: string` prop forwarded to GenericModal (+ `entityId` where applicable):
BillingPlanModal, SettingsModal, SupportModal, CreateDaemonModal, HostEditor, NetworkEditModal, TagEditModal, GroupEditModal, ServiceEditModal, DiscoveryEditModal, ShareModal, UserEditModal, InviteModal, UserApiKeyModal, SubnetEditModal, SnmpCredentialEditModal, ApiKeyModal (daemon), TopologyModal.

### Parent tabs with deep-link watchers (14 files)

Each parent tab added:
1. Import of `modalState`/`closeModal`
2. `$effect` watcher that opens the modal from store state, finds entity by ID in existing query data
3. `name` prop on the modal component instance

Tabs: HostTab, NetworksTab, TagTab, GroupTab, ServiceTab, ShareTab, SubnetTab, SnmpCredentialsTab, UserTab (2 modals), UserApiKeyTab, ApiKeyTab (daemon), TopologyTab, DaemonTab, DiscoveryScheduledTab.

### Deprecated one-off triggers replaced

| Old Pattern | New Pattern | Files Changed |
|---|---|---|
| `?auth_modal` URL param + backend | `?modal=settings` | Sidebar.svelte, backend auth/handlers.rs |
| `sessionStorage.showDaemonSetup` | `?modal=create-daemon` URL param | +page.svelte, onboarding/+page.svelte, DaemonTab.svelte |
| `showBillingPlanModal` writable store | `openModal('billing-plan')` | billing/stores.ts, UpgradeButton, Sidebar, BillingTab, CreateDaemonForm, DiscoveryTypeForm, +page.svelte |
| `reopenSettingsAfterBilling` + `showBillingPlanModal` combo | `reopenSettingsAfterBilling` flag + `openModal('settings', { tab: 'billing' })` | BillingTab.svelte, +page.svelte, Sidebar.svelte |
| Past-due forced settings `showSettings = true` | `openModal('settings', { tab: 'billing' })` | +page.svelte |

### Additional changes

- **`ui/src/lib/shared/utils/navigation.ts`**: Added `navigateWithModal()` for onboarding→daemon flow
- **`backend/src/server/auth/handlers.rs`**: Changed `append_pair("auth_modal", "true")` to `append_pair("modal", "settings")`

### Verification

- `cargo check`: passes
- `cargo test --lib`: 110 tests pass
- `npm test`: 14 tests pass (3 test files)
- `eslint`: passes (fixed unused `navigate` import in onboarding page)
- `svelte-check`: only pre-existing `$lib/paraglide/messages` errors (generated module)
- `make format`: clean
