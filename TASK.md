> **First:** Read `CLAUDE.md` (project instructions) — you are a **worker**. Start in **plan mode** and propose your implementation before coding.

<<<<<<< HEAD
# Task: Add Email Verification to User Registration

## Objective

Implement email verification step during user registration. New users must verify their email address before their account becomes active.

## Background

The codebase already has email infrastructure:
- `backend/src/server/email/` - Email service with Plunk and SMTP providers
- `EmailProvider` trait with `send_password_reset()` and `send_invite()` methods
- HTML email templates in `templates.rs`

## Requirements

### Backend

1. **Database changes**
   - Add `email_verified: bool` column to users table (default false)
   - Add `email_verification_token: Option<String>` column
   - Add `email_verification_expires: Option<DateTime>` column

2. **Email verification endpoint**
   - `POST /api/auth/verify-email` - accepts token, marks user as verified
   - `POST /api/auth/resend-verification` - generates new token, sends email

3. **Registration flow changes**
   - On registration, generate verification token
   - Send verification email with link
   - User cannot login until verified (or limited access)

4. **EmailProvider extension**
   - Add `send_verification_email()` method to trait
   - Add email template for verification

5. **Token handling**
   - Secure random token generation
   - Expiration time (suggest 24 hours)
   - Single-use tokens

### Frontend

1. **Registration feedback**
   - After registration, show "check your email" message
   - Provide "resend verification" option

2. **Verification page**
   - `/verify-email?token=xxx` route
   - Show success/error state
   - Redirect to login on success

3. **Login handling**
   - Show appropriate error if email not verified
   - Offer to resend verification email

## Acceptance Criteria

- [ ] New users receive verification email on registration
- [ ] Clicking verification link activates account
- [ ] Unverified users cannot login (or have limited access)
- [ ] Verification tokens expire after 24 hours
- [ ] Users can request new verification email
- [ ] Existing users unaffected (migration sets verified=true)

## Files Likely Involved

### Backend
- `backend/migrations/` - New migration for columns
- `backend/src/server/email/traits.rs` - New method
- `backend/src/server/email/templates.rs` - New template
- `backend/src/server/auth/handlers.rs` - New endpoints
- `backend/src/server/auth/service.rs` - Verification logic
- `backend/src/server/users/impl/base.rs` - User model changes

### Frontend
- `ui/src/routes/` - New verify-email route
- `ui/src/lib/features/auth/` - Registration/login updates
- `ui/src/lib/api/` - New API calls

## Notes

- Follow existing email patterns exactly
- Verification link format: `{base_url}/verify-email?token={token}`
- Consider rate limiting resend endpoint
=======
# Task: Scope Weblate Integration for Translations

## Objective

Research and document implementation plan for integrating Weblate to enable community translations of the Scanopy UI.

## Background

Weblate is an open-source web-based translation management system. It can:
- Host translation files and provide web UI for translators
- Sync with git repositories
- Support various i18n formats (JSON, PO, XLIFF, etc.)

## Research Questions

### 1. Current i18n State
- Does the UI currently have any i18n infrastructure?
- What framework is the frontend using (SvelteKit based on typical patterns)?
- Are there any existing translation files or string externalization?

### 2. i18n Library Selection
- What i18n libraries work well with the frontend framework?
- Options: svelte-i18n, typesafe-i18n, paraglide-js, etc.
- Considerations: type safety, bundle size, SSR support

### 3. String Extraction
- How many translatable strings exist approximately?
- What format should translation files use?
- Key naming conventions

### 4. Weblate Setup Options
- Self-hosted vs hosted.weblate.org
- Git integration approach (push/pull)
- Project structure in Weblate

### 5. Workflow
- How do new strings get added?
- How do translations get into the app?
- CI/CD integration
- Handling missing translations (fallback)

### 6. Scope Estimate
- Effort to add i18n infrastructure
- Effort to extract existing strings
- Ongoing maintenance burden

## Deliverables

1. **Current state assessment** - Existing i18n infrastructure (if any)
2. **Recommended approach** - i18n library, file format, workflow
3. **Weblate configuration** - How to set up project
4. **Implementation plan** - Steps to add i18n support
5. **Effort estimate** - Rough sizing (small/medium/large)

## Research Approach

1. Examine frontend codebase structure
2. Check for existing i18n/l10n code
3. Identify translatable strings (UI text, error messages, etc.)
4. Research i18n libraries compatible with framework
5. Review Weblate documentation for integration options

## Files to Examine

- `ui/src/` - Frontend source
- `ui/package.json` - Dependencies, scripts
- `ui/src/lib/` - Shared components (likely contain UI strings)
- Any existing locale/i18n directories

## Notes

- This is research/scoping, not implementation
- Focus on practical, maintainable approach
- Consider translator experience (Weblate UI quality)
- Document findings in TASK.md work summary
>>>>>>> weblate-scoping

---

## Work Summary

<<<<<<< HEAD
### What was implemented

Email verification for user registration with the following features:
- New users must verify email before logging in
- OIDC users are auto-verified (identity provider already verifies)
- Self-hosted instances without email service auto-verify users on registration
- Password reset tokens migrated from in-memory HashMap to database for persistence across restarts and multi-instance deployments
- 60-second rate limiting on verification email resend

### Files Changed

**Backend:**
- `backend/migrations/20260110000000_email_verification.sql` - New migration adding 5 columns (email_verified, email_verification_token, email_verification_expires, password_reset_token, password_reset_expires) with indexes
- `backend/src/server/users/impl/base.rs` - Added new fields to UserBase struct, updated new_password/new_oidc constructors
- `backend/src/server/email/templates.rs` - Added EMAIL_VERIFICATION_TITLE and EMAIL_VERIFICATION_BODY constants
- `backend/src/server/email/traits.rs` - Added build_verification_email() and send_verification_email() to EmailProvider trait
- `backend/src/server/email/plunk.rs` - Implemented send_verification_email()
- `backend/src/server/email/smtp.rs` - Implemented send_verification_email()
- `backend/src/server/auth/service.rs` - Major changes: removed in-memory password_reset_tokens, added verification methods, modified register() and try_login()
- `backend/src/server/auth/handlers.rs` - Added verify_email and resend_verification routes and handlers
- `backend/src/server/auth/impl/api.rs` - Added VerifyEmailRequest and ResendVerificationRequest types
- `backend/src/server/shared/services/factory.rs` - Updated AuthService::new() to pass public_url
- `backend/src/server/shared/types/examples.rs` - Added new fields to example User

**Frontend:**
- `ui/src/lib/features/auth/types/base.ts` - Exported new request types
- `ui/src/lib/features/auth/queries.ts` - Added useVerifyEmailMutation() and useResendVerificationMutation()
- `ui/src/routes/verify-email/+page.svelte` - New verification page with multiple states
- `ui/src/lib/shared/components/layout/AppShell.svelte` - Added /verify-email to public routes
- `ui/src/routes/onboarding/+page.svelte` - Redirect to verify-email when user.email_verified is false
- `ui/src/routes/login/+page.svelte` - Handle EMAIL_NOT_VERIFIED error by redirecting to verify-email

### Endpoints Added

| Endpoint | Permission | Tenant Isolation |
|----------|------------|------------------|
| `POST /api/auth/verify-email` | Public (no auth) | Token-based validation, user lookup by token |
| `POST /api/auth/resend-verification` | Public (no auth) | Email-based lookup, rate limited |

These endpoints are public (like login/register) as they're used before authentication. Token validation ensures users can only verify their own accounts.

### Deviations from Original Task

1. **Added password reset token migration** - Per user request, migrated password reset tokens from in-memory storage to database for persistence across server restarts and multi-instance deployments
2. **Self-hosted fallback** - Added auto-verification for self-hosted instances without email service configured, ensuring they can still use the system
3. **Auto-login after verification** - Users are automatically logged in after successful verification (better UX than requiring re-login)

### Token Expiration

- Email verification: 24 hours
- Password reset: 1 hour (unchanged from original behavior)

### Acceptance Criteria Status

- [x] New users receive verification email on registration
- [x] Clicking verification link activates account
- [x] Unverified users cannot login (blocked with specific error)
- [x] Verification tokens expire after 24 hours
- [x] Users can request new verification email (with 60s rate limit)
- [x] Existing users unaffected (migration sets verified=true)
=======
### Current State Assessment

**Frontend Stack:** SvelteKit 2.43.5 + Svelte 5.0.0, Vite 7.1.3, static adapter

**i18n Infrastructure:** None exists
- No locale directories or translation files
- No i18n library installed
- All UI text hardcoded as English strings

**Codebase Metrics:**
- 110 Svelte component files
- 21 feature modules
- ~27,000 lines of Svelte code
- **600-800 estimated translatable strings**

**String Categories:**
- Form labels & placeholders: ~170 unique
- Validation/error messages: ~70
- Button labels & actions: ~270+ occurrences
- Toast notifications: ~50+
- Modal titles & headings: ~40+
- Empty states & help text: ~30+

### Recommended Approach

**i18n Library:** Paraglide JS
- Official Svelte CLI integration (first-party support)
- Compiler-based: generates tree-shakable message functions
- Full TypeScript support with type-safe message keys
- Small bundle impact (~1KB base + only used messages)

**File Format:** JSON with flat dot-notation keys
```json
{
  "common.save": "Save",
  "hosts.createHost": "Create Host",
  "validation.required": "This field is required"
}
```

**Key Naming:** `{namespace}.{camelCaseKey}`
- Namespaces: common, auth, hosts, networks, services, settings, validation, errors

### Weblate Configuration

**Hosting:** hosted.weblate.org (paid tier)

**Git Workflow:**
1. Developer adds strings → commits `en.json` → pushes to GitHub
2. Weblate pulls changes automatically (webhook)
3. Translators work in Weblate web UI
4. Weblate commits translations back to repo
5. CI builds with updated translations

**Project Structure:**
```
Project: Scanopy
└── Component: UI
    ├── Source: messages/en.json
    ├── File format: JSON
    ├── File mask: messages/*.json
    └── Languages: en (source), add others as community contributes
```

### Implementation Plan

**Phase 1: Infrastructure Setup**
- Install Paraglide JS and Vite plugin
- Create `project.inlang/` configuration
- Create `messages/en.json` with initial structure
- Add locale detection (browser → cookie → default)

Files to create: `ui/project.inlang/settings.json`, `ui/messages/en.json`, `ui/src/lib/i18n.ts`
Files to modify: `ui/vite.config.ts`, `ui/package.json`, `ui/src/routes/+layout.svelte`

**Phase 2: String Extraction (by priority)**
1. shared/components (~100 strings) - reused everywhere
2. auth (~50) - user-facing, critical
3. settings (~80) - user-facing
4. hosts (~100) - core feature
5. networks, services (~80) - core features
6. Remaining features (~400)

**Phase 3: Weblate Setup**
- Create project on hosted.weblate.org
- Connect GitHub repository
- Configure webhook for auto-sync
- Enable "Push on commit"

**Phase 4: CI/CD Integration**
- Add translation build step
- Validate message files (no missing keys)

### Decisions Made

- **Rollout:** Full string extraction before shipping (complete i18n coverage from day one)
- **Missing translations:** Fall back to English
- **Initial languages:** English only; add languages as community contributors volunteer

### Effort Estimate

| Task | Effort |
|------|--------|
| Paraglide setup | Small (~2 hours) |
| String extraction | Medium-Large (600-800 strings) |
| Weblate setup | Small (~1 hour) |
| CI integration | Small (~1 hour) |

**Total: Medium effort** - Infrastructure is straightforward; string extraction is the bulk of work but mechanical.

### Sources

- [Paraglide SvelteKit Documentation](https://inlang.com/m/dxnzrydw/paraglide-sveltekit-i18n/)
- [Svelte CLI Paraglide Docs](https://svelte.dev/docs/cli/paraglide)
- [Weblate Integration Guide](https://docs.weblate.org/en/latest/devel/integration.html)
- [Weblate Continuous Localization](https://docs.weblate.org/en/latest/admin/continuous.html)
>>>>>>> weblate-scoping
