//! Daemon service-level integration tests.
//!
//! These tests exercise daemon lifecycle behaviour that isn't covered by
//! the regular CRUD or discovery flows — e.g. re-registration semantics.

use crate::infra::{BASE_URL, exec_sql};
use uuid::Uuid;

pub async fn run_daemon_tests(
    daemon_id: Uuid,
    daemon_api_key: &str,
    network_id: Uuid,
    user_id: Uuid,
) -> Result<(), String> {
    println!("\n=== Testing Daemon Service Behaviour ===\n");

    test_reregistration_clears_standby(daemon_id, daemon_api_key, network_id, user_id).await?;

    println!("\n✅ All daemon service tests passed!");
    Ok(())
}

/// A daemon that's been put on standby (e.g. by the 30-day-inactive sweep)
/// should be flipped back to active when it re-registers with the same UUID.
/// Other fields on the daemon should also be refreshed from the new request.
async fn test_reregistration_clears_standby(
    daemon_id: Uuid,
    daemon_api_key: &str,
    network_id: Uuid,
    user_id: Uuid,
) -> Result<(), String> {
    println!("Testing re-registration clears standby...");

    exec_sql(&format!(
        "UPDATE daemons SET standby = true WHERE id = '{}';",
        daemon_id
    ))?;
    println!("  ✓ Marked daemon as standby via SQL");

    let new_name = "scanopy-daemon-serverpoll-reregistered";
    let new_version = "0.16.0";
    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/api/daemons/register", BASE_URL))
        .header("X-Daemon-ID", daemon_id.to_string())
        .header("Authorization", format!("Bearer {}", daemon_api_key))
        .json(&serde_json::json!({
            "daemon_id": daemon_id,
            "network_id": network_id,
            "name": new_name,
            "mode": "server_poll",
            "capabilities": {
                "has_docker_socket": false,
                "interfaced_subnet_ids": []
            },
            "user_id": user_id,
            "version": new_version,
        }))
        .send()
        .await
        .map_err(|e| format!("Failed to POST /api/daemons/register: {}", e))?;

    let status = response.status();
    let body: serde_json::Value = response
        .json()
        .await
        .map_err(|e| format!("Failed to parse registration response: {}", e))?;

    if !status.is_success() {
        return Err(format!(
            "Re-registration returned non-2xx: status={} body={}",
            status,
            serde_json::to_string_pretty(&body).unwrap_or_default()
        ));
    }
    println!("  ✓ POST /api/daemons/register returned {}", status);

    let daemon_obj = body
        .pointer("/data/daemon")
        .ok_or_else(|| format!("Response missing data.daemon: {}", body))?;

    let standby = daemon_obj
        .get("standby")
        .and_then(|v| v.as_bool())
        .ok_or_else(|| "Response daemon missing standby field".to_string())?;
    if standby {
        return Err("standby should be cleared after re-registration but was still true".into());
    }
    println!("  ✓ standby == false after re-registration");

    let returned_name = daemon_obj
        .get("name")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "Response daemon missing name field".to_string())?;
    if returned_name != new_name {
        return Err(format!(
            "Expected name to be refreshed to {:?}, got {:?}",
            new_name, returned_name
        ));
    }
    println!("  ✓ name refreshed to {}", returned_name);

    let returned_version = daemon_obj
        .get("version")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "Response daemon missing version field".to_string())?;
    if returned_version != new_version {
        return Err(format!(
            "Expected version to be refreshed to {:?}, got {:?}",
            new_version, returned_version
        ));
    }
    println!("  ✓ version refreshed to {}", returned_version);

    let last_seen = daemon_obj
        .get("last_seen")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "Response daemon missing last_seen field".to_string())?;
    if last_seen.is_empty() {
        return Err("last_seen should have been refreshed to a non-empty timestamp".into());
    }
    println!("  ✓ last_seen refreshed to {}", last_seen);

    Ok(())
}
