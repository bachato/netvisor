//! API compatibility tests.
//!
//! These tests verify that the server and daemon can handle requests from
//! different versions, ensuring backwards compatibility.
//!
//! ## Fixture Generation
//!
//! Fixtures are automatically captured during integration tests when running
//! with `--features generate-fixtures`:
//!
//! - `daemon_to_server.json`: Requests the daemon makes to the server
//! - `server_to_daemon.json`: Requests the server makes to the daemon
//! - `openapi.json`: OpenAPI spec for schema validation
//!
//! ## Replay Testing
//!
//! Replay tests load fixtures and make actual HTTP requests to verify
//! compatibility. IDs in paths and bodies are substituted with test values.
//! Response bodies are validated against the captured OpenAPI schema.

mod replay;
mod schema;
mod types;

pub use replay::*;

use uuid::Uuid;

const SERVER_URL: &str = "http://localhost:60072";
const DAEMON_URL: &str = "http://localhost:60073";

/// Run all compatibility tests against running server and daemon.
pub async fn run_compat_tests(
    daemon_id: Uuid,
    network_id: Uuid,
    organization_id: Uuid,
    user_id: Uuid,
) -> Result<(), String> {
    let ctx = ReplayContext {
        daemon_id,
        network_id,
        user_id,
        organization_id,
        api_key: String::new(), // Daemon auth uses X-Daemon-ID header
    };

    println!("\n=== Server Compatibility (old daemon → current server) ===");
    run_server_compat_tests(SERVER_URL, &ctx).await?;

    println!("\n=== Daemon Compatibility (old server → current daemon) ===");
    run_daemon_compat_tests(DAEMON_URL, &ctx).await?;

    println!("\n✅ All compatibility tests passed!");
    Ok(())
}
