# API Versioning Design

## Overview

Add URL-based API versioning (`/api/v1/...`) and response metadata to enable compatibility checking for community integrations.

## Goals

1. Version the API via URL path prefix (`/api/v1/`)
2. Include version metadata in all API responses
3. Provide a `/api/version` endpoint for compatibility checking

## Non-Goals

- Multiple concurrent API versions (v2 support is future work)
- Header-based or query-param versioning
- Client SDK changes (out of scope)

---

## Design

### 1. URL Path Versioning

**Current:** `/api/hosts`, `/api/networks`, etc.

**Proposed:** `/api/v1/hosts`, `/api/v1/networks`, etc.

#### Changes to `shared/handlers/factory.rs`

```rust
pub fn create_openapi_routes() -> OpenApiRouter<Arc<AppState>> {
    // Versioned routes - REST resources
    let v1_routes = OpenApiRouter::new()
        .nest("/hosts", host_handlers::create_router())
        .nest("/interfaces", interface_handlers::create_router())
        .nest("/subnets", subnet_handlers::create_router())
        // ... all other entity routes
        .nest("/auth/keys", user_api_key_handlers::create_router())
        .nest("/auth/daemon", daemon_api_key_handlers::create_router())
        .nest("/topology", topology_handlers::create_router());

    // Unversioned routes - session auth, system endpoints
    let unversioned_routes = OpenApiRouter::new()
        .nest("/auth", auth_handlers::create_router())  // login, logout, callback
        .routes(routes!(get_version));                   // /api/version

    OpenApiRouter::new()
        .nest("/api/v1", v1_routes)
        .nest("/api", unversioned_routes)
}
```

Note: `/api/health` is registered separately in `server.rs` outside the middleware stack.

### 2. Response Metadata

#### Updated `ApiResponse` Type

**File:** `shared/types/api.rs`

```rust
use semver::Version;

/// API version metadata included in all responses
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct ApiMeta {
    /// API version (integer, increments on breaking changes)
    pub api_version: u32,
    /// Server version (semver)
    #[schema(value_type = String, example = "0.12.10")]
    pub server_version: Version,
}

impl Default for ApiMeta {
    fn default() -> Self {
        Self {
            api_version: 1,
            server_version: Version::parse(env!("CARGO_PKG_VERSION")).unwrap(),
        }
    }
}

#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct ApiResponse<T> {
    pub success: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<T>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
    pub meta: ApiMeta,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
            meta: ApiMeta::default(),
        }
    }

    pub fn error(message: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message),
            meta: ApiMeta::default(),
        }
    }
}
```

#### Response Shape

**Before:**
```json
{
  "success": true,
  "data": { "id": "...", "name": "..." },
  "error": null
}
```

**After:**
```json
{
  "success": true,
  "data": { "id": "...", "name": "..." },
  "meta": {
    "api_version": 1,
    "server_version": "0.12.10"
  }
}
```

Note: `error` field omitted when null (cleaner responses).

### 3. Version Endpoint

**Path:** `GET /api/version` (unversioned, always accessible)

**File:** New handler in `shared/handlers/version.rs` or inline in `factory.rs`

```rust
use semver::Version;

/// Version information for API compatibility checking
#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct VersionInfo {
    /// Current API version
    pub api_version: u32,
    /// Server version (semver)
    #[schema(value_type = String, example = "0.12.10")]
    pub server_version: Version,
    /// Minimum client version that can use this API (optional, for future use)
    #[serde(skip_serializing_if = "Option::is_none")]
    #[schema(value_type = Option<String>, example = "0.12.0")]
    pub min_compatible_client: Option<Version>,
}

#[utoipa::path(
    get,
    path = "/api/version",
    tag = "system",
    responses(
        (status = 200, description = "Version information", body = ApiResponse<VersionInfo>)
    )
)]
pub async fn get_version() -> Json<ApiResponse<VersionInfo>> {
    Json(ApiResponse::success(VersionInfo {
        api_version: 1,
        server_version: Version::parse(env!("CARGO_PKG_VERSION")).unwrap(),
        min_compatible_client: None,
    }))
}
```

**Registration:** Add to router outside versioned prefix (like `/api/health`):

```rust
// In factory.rs or server.rs
.route("/api/version", get(get_version))
```

---

## Files Changed

| File | Change |
|------|--------|
| `shared/types/api.rs` | Add `ApiMeta`, update `ApiResponse` |
| `shared/handlers/factory.rs` | Nest routes under `/api/v1`, add `/api/version`, keep auth unversioned |
| `openapi.rs` | Set `info.version` to `"1"` (API version) |

**Frontend (after `make generate-types`):**
| File | Change |
|------|--------|
| `ui/src/lib/api/schema.d.ts` | Regenerated with new `ApiMeta` type |
| `ui/src/lib/api/*.ts` | Update base URL to `/api/v1` |
| `ui/src/lib/api/client.ts` | Handle new response shape with `meta` field |

---

## Implementation Plan

### Phase 1: Backend Changes
1. Add `ApiMeta` struct to `shared/types/api.rs`
2. Update `ApiResponse` to include `meta` field
3. Add `/api/version` endpoint
4. Move all routes to `/api/v1/` prefix in `factory.rs`
5. Run `cargo test` to verify

### Phase 2: Frontend Changes
1. Run `make generate-types` to regenerate TypeScript types
2. Update API client base URL from `/api/` to `/api/v1/`
3. Update any code that destructures API responses to handle `meta` field
4. Run `npm test` to verify

### Phase 3: Documentation
1. Update API documentation with versioning info
2. Document version policy (when v2 would be introduced)

---

## Decisions

### Unversioned Endpoints

The following endpoints stay **unversioned** (outside `/api/v1/`):

| Endpoint | Rationale |
|----------|-----------|
| `/api/health` | Infrastructure endpoint for load balancers/monitoring |
| `/api/version` | Must be accessible to check version before knowing which version to use |
| `/api/auth/login` | Session management, not REST resources |
| `/api/auth/logout` | Session management, not REST resources |
| `/api/auth/callback` | OAuth callback, tied to auth provider not API version |

Session-based auth endpoints are kept unversioned because:
- They manage sessions, not data resources
- Breaking changes are rare and usually mean adding new endpoints (e.g., `/api/auth/oauth2/callback`)
- Versioning would add complexity without clear benefit

### OpenAPI Spec Versioning

Single spec with `info.version` set to API version:

**File:** `openapi.rs`

```rust
#[derive(OpenApi)]
#[openapi(
    info(
        title = "Scanopy API",
        version = "1",  // API version, not server version
        description = "..."
    ),
    // ...
)]
pub struct ApiDoc;
```

The `info.version` field represents the API contract version (1, 2, etc.), distinct from the server version (0.12.10). Clients can check this field to verify compatibility.

---

## Future Considerations

- **v2 introduction:** When v2 is needed, add `/api/v2/` routes alongside v1
- **Deprecation headers:** Add `Deprecation` and `Sunset` headers when deprecating v1
- **Version negotiation:** Could add `Accept-Version` header support later if needed
