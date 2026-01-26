//! Integration test suite for Scanopy.
//!
//! This module runs all integration tests in a single test function to share
//! Docker containers across test categories, significantly reducing test time.
//!
//! Test categories:
//! - Full integration flow (auth, discovery, entity creation)
//! - CRUD endpoint tests
//! - Billing middleware tests
//! - Handler validation tests

mod billing;
mod compat;
mod crud;
mod discovery;
#[cfg(feature = "generate-fixtures")]
mod fixtures;
mod infra;
mod openapi_gen;
mod permissions;
mod validations;

use infra::{
    ContainerManager, TestClient, TestContext, clear_discovery_data, create_test_db_pool,
    provision_serverpoll_daemon, setup_authenticated_user, wait_for_daemon, wait_for_network,
    wait_for_organization,
};

/// Single integration test that runs all test categories with shared containers.
///
/// This avoids spinning up/down containers for each test category, which saves
/// significant time (each container cycle takes ~30-60 seconds).
#[tokio::test]
async fn integration_tests() {
    let mut container_manager = ContainerManager::new();

    // Start containers once
    container_manager
        .start()
        .expect("Failed to start containers");

    let client = TestClient::new();

    // =========================================================================
    // Phase 1a: DaemonPoll Integration Flow
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 1a: DaemonPoll Integration Flow");
    println!("============================================================\n");

    let user = setup_authenticated_user(&client)
        .await
        .expect("Failed to authenticate user");
    println!("✅ Authenticated as: {}", user.base.email);

    println!("\n=== Waiting for Organization ===");
    let organization = wait_for_organization(&client)
        .await
        .expect("Failed to find organization");
    println!("✅ Organization: {}", organization.base.name);

    println!("\n=== Waiting for Network ===");
    let network = wait_for_network(&client)
        .await
        .expect("Failed to find network");
    println!("✅ Network: {}", network.base.name);

    println!("\n=== Waiting for DaemonPoll Daemon ===");
    let daemon = wait_for_daemon(&client)
        .await
        .expect("Failed to find daemon");
    println!("✅ DaemonPoll daemon registered: {}", daemon.id);

    // Run discovery with DaemonPoll daemon
    discovery::run_discovery(&client)
        .await
        .expect("DaemonPoll discovery failed");

    // Verify service discovered
    let _service = discovery::verify_home_assistant_discovered(&client)
        .await
        .expect("Failed to find Home Assistant");

    let _group = discovery::create_group(&client, network.id)
        .await
        .expect("Failed to create group");
    let _tag = discovery::create_tag(&client, organization.id)
        .await
        .expect("Failed to create tag");

    println!("\n✅ DaemonPoll integration flow completed!");

    // =========================================================================
    // Phase 1b: ServerPoll Integration Flow
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 1b: ServerPoll Integration Flow");
    println!("============================================================\n");

    // Clear discovery data from DaemonPoll run
    clear_discovery_data().expect("Failed to clear discovery data");

    // Provision and initialize ServerPoll daemon
    let serverpoll_provision = provision_serverpoll_daemon(&client, network.id)
        .await
        .expect("Failed to provision ServerPoll daemon");
    let serverpoll_api_key = serverpoll_provision.daemon_api_key.clone();

    // Run discovery with ServerPoll daemon
    discovery::run_discovery(&client)
        .await
        .expect("ServerPoll discovery failed");

    // Verify service discovered
    let _service = discovery::verify_home_assistant_discovered(&client)
        .await
        .expect("Failed to find Home Assistant (ServerPoll)");

    println!("\n✅ ServerPoll integration flow completed!");

    // Clear discovery data before other tests
    clear_discovery_data().expect("Failed to clear discovery data");

    // =========================================================================
    // Phase 2: CRUD Endpoint Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 2: CRUD Endpoint Tests");
    println!("============================================================");

    let db_pool = create_test_db_pool()
        .await
        .expect("Failed to create test database pool");

    let ctx = TestContext {
        client: TestClient::new(),
        network_id: network.id,
        organization_id: organization.id,
        db_pool,
    };

    // Re-authenticate for CRUD tests
    let _ = setup_authenticated_user(&ctx.client)
        .await
        .expect("Failed to re-authenticate");

    crud::run_crud_tests(&ctx).await.expect("CRUD tests failed");

    // =========================================================================
    // Phase 3: Billing Middleware Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 3: Billing Middleware Tests");
    println!("============================================================");

    billing::run_billing_tests(&ctx)
        .await
        .expect("Billing tests failed");

    // =========================================================================
    // Phase 4: Handler Validation Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 4: Handler Validation Tests");
    println!("============================================================");

    validations::run_validation_tests(&ctx)
        .await
        .expect("Validation tests failed");

    // =========================================================================
    // Phase 5: Permission & Access Control Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 5: Permission & Access Control Tests");
    println!("============================================================");

    permissions::run_permission_tests(&ctx)
        .await
        .expect("Permission tests failed");

    // =========================================================================
    // Phase 6: Generate Fixtures (optional)
    // =========================================================================
    #[cfg(feature = "generate-fixtures")]
    {
        println!("\n============================================================");
        println!("Phase 6: Generating Fixtures");
        println!("============================================================");

        fixtures::generate_fixtures().await;
    }

    // =========================================================================
    // Phase 7: API Compatibility Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 7: API Compatibility Tests");
    println!("============================================================");

    compat::run_compat_tests(
        daemon.id,
        network.id,
        organization.id,
        user.id,
        &serverpoll_api_key,
    )
    .await
    .expect("Compatibility tests failed");

    // =========================================================================
    // Summary
    // =========================================================================
    println!("\n============================================================");
    println!("ALL INTEGRATION TESTS PASSED!");
    println!("============================================================");
    println!("   - DaemonPoll integration flow");
    println!("   - ServerPoll integration flow");
    println!("   - CRUD endpoint tests");
    println!("   - Billing middleware tests");
    println!("   - Handler validation tests");
    println!("   - Permission & access control tests");
    #[cfg(feature = "generate-fixtures")]
    println!("   - Fixture generation");
    println!("   - API compatibility tests");
}
