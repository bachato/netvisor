use crate::server::{
    bindings::r#impl::base::Binding,
    credentials::r#impl::base::Credential,
    daemon_api_keys::r#impl::base::DaemonApiKey,
    daemons::r#impl::base::Daemon,
    dependencies::{dependency_members::DependencyMemberRecord, r#impl::base::Dependency},
    discovery::r#impl::base::Discovery,
    hosts::r#impl::base::Host,
    interfaces::r#impl::base::Interface,
    invites::r#impl::base::Invite,
    ip_addresses::r#impl::base::IPAddress,
    networks::r#impl::Network,
    organizations::r#impl::base::Organization,
    ports::r#impl::base::Port,
    services::r#impl::base::Service,
    shared::storage::traits::Storable,
    shares::r#impl::base::Share,
    subnets::r#impl::base::Subnet,
    tags::entity_tags::EntityTag,
    tags::r#impl::base::Tag,
    topology::types::base::Topology,
    user_api_keys::r#impl::base::UserApiKey,
    users::r#impl::base::User,
    vlans::r#impl::{base::Vlan, subnet_vlans::SubnetVlanRecord},
};
use sqlx::postgres::PgRow;
use std::collections::HashMap;

// Type alias for the deserialization function
#[allow(dead_code)]
type DeserializeFn = Box<dyn Fn(&PgRow) -> Result<(), anyhow::Error> + Send + Sync>;

#[allow(dead_code)]
const TABLES_WITHOUT_ENTITIES: [&str; 2] = ["user_network_access", "user_api_key_network_access"];

// Mapping from table name to deserialization function
#[allow(dead_code)]
fn get_entity_deserializers() -> HashMap<&'static str, DeserializeFn> {
    let mut map: HashMap<&'static str, DeserializeFn> = HashMap::new();

    map.insert(
        DaemonApiKey::table_name(),
        Box::new(|row| {
            DaemonApiKey::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Daemon::table_name(),
        Box::new(|row| {
            Daemon::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Discovery::table_name(),
        Box::new(|row| {
            Discovery::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Dependency::table_name(),
        Box::new(|row| {
            Dependency::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Host::table_name(),
        Box::new(|row| {
            Host::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Network::table_name(),
        Box::new(|row| {
            Network::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Organization::table_name(),
        Box::new(|row| {
            Organization::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Service::table_name(),
        Box::new(|row| {
            Service::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Subnet::table_name(),
        Box::new(|row| {
            Subnet::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        User::table_name(),
        Box::new(|row| {
            User::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Topology::table_name(),
        Box::new(|row| {
            Topology::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Tag::table_name(),
        Box::new(|row| {
            Tag::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Invite::table_name(),
        Box::new(|row| {
            Invite::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Share::table_name(),
        Box::new(|row| {
            Share::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        IPAddress::table_name(),
        Box::new(|row| {
            IPAddress::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Port::table_name(),
        Box::new(|row| {
            Port::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Binding::table_name(),
        Box::new(|row| {
            Binding::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        DependencyMemberRecord::table_name(),
        Box::new(|row| {
            DependencyMemberRecord::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        UserApiKey::table_name(),
        Box::new(|row| {
            UserApiKey::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        EntityTag::table_name(),
        Box::new(|row| {
            EntityTag::from_row(row)?;
            Ok(())
        }),
    );

    // snmp_credentials table was dropped by universal_credentials migration
    // SnmpCredential deserializer is no longer needed

    map.insert(
        Credential::table_name(),
        Box::new(|row| {
            Credential::from_row(row)?;
            Ok(())
        }),
    );

    // Junction tables for multi-credential support — no entity struct, just verify readable
    map.insert("host_credentials", Box::new(|_row| Ok(())));

    map.insert("network_credentials", Box::new(|_row| Ok(())));

    map.insert(
        Interface::table_name(),
        Box::new(|row| {
            Interface::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        Vlan::table_name(),
        Box::new(|row| {
            Vlan::from_row(row)?;
            Ok(())
        }),
    );

    map.insert(
        SubnetVlanRecord::table_name(),
        Box::new(|row| {
            SubnetVlanRecord::from_row(row)?;
            Ok(())
        }),
    );

    map
}

#[tokio::test]
pub async fn test_all_tables_have_entity_mapping() {
    use crate::tests::setup_test_db;

    let (pool, _database_url, _container) = setup_test_db().await;

    // Apply migrations to create the schema
    sqlx::migrate!("./migrations")
        .run(&pool)
        .await
        .expect("Failed to run migrations");

    // Get all tables from information_schema
    let tables: Vec<String> = sqlx::query_scalar(
        "SELECT table_name FROM information_schema.tables
         WHERE table_schema = 'public'
         AND table_type = 'BASE TABLE'
         AND table_name != '_sqlx_migrations'",
    )
    .fetch_all(&pool)
    .await
    .expect("Failed to fetch table names");

    let deserializers = get_entity_deserializers();

    println!("Verifying entity mappings for all tables...");

    let mut missing_mappings = Vec::new();
    for table in &tables {
        if !deserializers.contains_key(table.as_str())
            && !TABLES_WITHOUT_ENTITIES.contains(&table.as_str())
        {
            missing_mappings.push(table.clone());
        }
    }

    if !missing_mappings.is_empty() {
        panic!(
            "The following tables are missing entity mappings in get_entity_deserializers():\n  - {}\n\
             Please add them to the registry.",
            missing_mappings.join("\n  - ")
        );
    }

    println!("✓ All {} tables have entity mappings", tables.len());
}

#[tokio::test]
pub async fn test_database_schema_backward_compatibility() {
    use crate::tests::SERVER_DB_FIXTURE;
    use crate::tests::setup_test_db;
    use std::path::Path;

    let db_path = Path::new(SERVER_DB_FIXTURE);

    if db_path.exists() {
        use std::process::Command;

        println!("Testing backward compatibility with database from latest release");

        let (pool, database_url, _container) = setup_test_db().await;

        let url = url::Url::parse(&database_url).unwrap();
        let host = url.host_str().unwrap();
        let port = url.port().unwrap();
        let database = url.path().trim_start_matches('/');

        pool.close().await;

        let output = Command::new("psql")
            .arg("-h")
            .arg(host)
            .arg("-p")
            .arg(port.to_string())
            .arg("-U")
            .arg("postgres")
            .arg("-d")
            .arg(database)
            .arg("-f")
            .arg(db_path)
            .env("PGPASSWORD", "password")
            .output()
            .expect("Failed to execute psql - ensure it's installed");

        assert!(
            output.status.success(),
            "Failed to restore database:\n{}",
            String::from_utf8_lossy(&output.stderr)
        );

        println!("Successfully restored database from fixture");

        let pool = sqlx::PgPool::connect(&database_url).await.unwrap();

        // Verify tables exist using the deserializers map
        let deserializers = get_entity_deserializers();
        for table_name in deserializers.keys() {
            // Check if table exists in the old schema
            let table_exists: bool = sqlx::query_scalar(
                "SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_name = $1
                )",
            )
            .bind(table_name)
            .fetch_one(&pool)
            .await
            .unwrap();

            if !table_exists {
                println!(
                    "Table '{}' doesn't exist in old schema (new entity), skipping",
                    table_name
                );
                continue;
            }

            assert!(
                sqlx::query(&format!("SELECT * FROM {}", table_name))
                    .fetch_all(&pool)
                    .await
                    .is_ok(),
                "Failed to read table: {}",
                table_name
            );
        }

        println!("Successfully read all tables from latest release database");

        sqlx::migrate!("./migrations")
            .run(&pool)
            .await
            .expect("Failed to apply current schema to old database");

        println!("Successfully applied current schema to old database");
    } else {
        panic!("No database fixture found at {}", SERVER_DB_FIXTURE);
    }
}

#[tokio::test]
pub async fn test_struct_deserialization_backward_compatibility() {
    use crate::tests::SERVER_DB_FIXTURE;
    use crate::tests::setup_test_db;
    use std::path::Path;

    let db_path = Path::new(SERVER_DB_FIXTURE);

    if db_path.exists() {
        use std::process::Command;

        println!("Testing struct deserialization from migrated old schema");

        let (pool, database_url, _container) = setup_test_db().await;

        let url = url::Url::parse(&database_url).unwrap();
        let host = url.host_str().unwrap();
        let port = url.port().unwrap();
        let database = url.path().trim_start_matches('/');

        pool.close().await;

        // Restore old database
        let output = Command::new("psql")
            .arg("-h")
            .arg(host)
            .arg("-p")
            .arg(port.to_string())
            .arg("-U")
            .arg("postgres")
            .arg("-d")
            .arg(database)
            .arg("-f")
            .arg(db_path)
            .env("PGPASSWORD", "password")
            .output()
            .expect("Failed to execute psql");

        assert!(
            output.status.success(),
            "Failed to restore database:\n{}",
            String::from_utf8_lossy(&output.stderr)
        );

        let pool = sqlx::PgPool::connect(&database_url).await.unwrap();

        // Apply current migrations
        sqlx::migrate!("./migrations")
            .run(&pool)
            .await
            .expect("Failed to apply current schema");

        println!("Testing deserialization of all entity types...");

        let deserializers = get_entity_deserializers();

        for (table_name, deserialize_fn) in deserializers.iter() {
            let rows = sqlx::query(&format!("SELECT * FROM {}", table_name))
                .fetch_all(&pool)
                .await
                .expect(&format!("Failed to fetch {}", table_name));

            for row in rows.iter() {
                deserialize_fn(row)
                    .expect(&format!("Failed to deserialize row from {}", table_name));
            }

            println!(
                "✓ Successfully deserialized {} rows from {}",
                rows.len(),
                table_name
            );
        }

        println!("All entity types deserialized successfully from migrated schema");
    } else {
        panic!("No database fixture found at {}", SERVER_DB_FIXTURE);
    }
}

/// Compares each entity's `to_params()` column list against the live
/// `information_schema.columns` for its table. Fails on:
///   - Columns in `to_params()` that don't exist in the live schema (storage
///     would SELECT/INSERT a missing column).
///   - Live NOT-NULL columns without a default that aren't in `to_params()`
///     (entity INSERTs would omit a required column).
///
/// Complement to the release-time container harness — that catches drift at
/// runtime against the previously-deployed binary, this catches code/schema
/// drift within the current binary at `cargo test --lib` time.
///
/// `#[ignore]`-gated because it spins up a testcontainer; opt in with:
///   `cargo test --lib test_entity_columns_match_live_schema -- --ignored`
#[tokio::test]
#[ignore]
pub async fn test_entity_columns_match_live_schema() {
    use crate::server::shared::storage::traits::Storable;
    use crate::tests::setup_test_db;

    let (pool, _database_url, _container) = setup_test_db().await;
    sqlx::migrate!("./migrations")
        .run(&pool)
        .await
        .expect("Failed to run migrations");

    /// For a Storable type, fetch the live column spec for its table and
    /// compare against what to_params() produces. Pushes human-readable
    /// failure strings into `failures`.
    async fn check_entity<T: Storable>(pool: &sqlx::PgPool, failures: &mut Vec<String>) {
        let table = T::table_name();
        let insert_columns: Vec<&'static str> = T::default()
            .to_params()
            .expect("to_params should succeed on Default entity")
            .0;

        #[derive(sqlx::FromRow, Debug)]
        struct LiveColumn {
            column_name: String,
            is_nullable: String,
            column_default: Option<String>,
        }
        let live: Vec<LiveColumn> = sqlx::query_as(
            "SELECT column_name, is_nullable, column_default \
             FROM information_schema.columns \
             WHERE table_schema = 'public' AND table_name = $1",
        )
        .bind(table)
        .fetch_all(pool)
        .await
        .unwrap_or_else(|e| panic!("Failed to fetch columns for {}: {}", table, e));

        if live.is_empty() {
            failures.push(format!(
                "{}: table not found in live schema (but a Storable impl exists for it)",
                table
            ));
            return;
        }

        let live_names: std::collections::HashSet<&str> =
            live.iter().map(|c| c.column_name.as_str()).collect();

        for col in &insert_columns {
            if !live_names.contains(col) {
                failures.push(format!(
                    "{}: column {:?} in to_params() is missing from live schema",
                    table, col
                ));
            }
        }

        for col in &live {
            if col.is_nullable == "NO"
                && col.column_default.is_none()
                && !insert_columns.contains(&col.column_name.as_str())
            {
                failures.push(format!(
                    "{}: live schema has NOT NULL column {:?} with no default, \
                     but it's absent from to_params() — INSERTs will fail",
                    table, col.column_name
                ));
            }
        }
    }

    let mut failures: Vec<String> = Vec::new();

    // Exhaustive list of Storable entities — should stay in sync with
    // get_entity_deserializers above. Adding an entity: add an entry here and
    // there together.
    check_entity::<DaemonApiKey>(&pool, &mut failures).await;
    check_entity::<Daemon>(&pool, &mut failures).await;
    check_entity::<Discovery>(&pool, &mut failures).await;
    check_entity::<Dependency>(&pool, &mut failures).await;
    check_entity::<Host>(&pool, &mut failures).await;
    check_entity::<Network>(&pool, &mut failures).await;
    check_entity::<Organization>(&pool, &mut failures).await;
    check_entity::<Service>(&pool, &mut failures).await;
    check_entity::<Subnet>(&pool, &mut failures).await;
    check_entity::<IPAddress>(&pool, &mut failures).await;
    check_entity::<Invite>(&pool, &mut failures).await;
    check_entity::<Share>(&pool, &mut failures).await;
    check_entity::<User>(&pool, &mut failures).await;
    check_entity::<UserApiKey>(&pool, &mut failures).await;
    check_entity::<Tag>(&pool, &mut failures).await;
    check_entity::<Topology>(&pool, &mut failures).await;
    check_entity::<Port>(&pool, &mut failures).await;
    check_entity::<Binding>(&pool, &mut failures).await;
    check_entity::<Credential>(&pool, &mut failures).await;
    check_entity::<Interface>(&pool, &mut failures).await;
    check_entity::<Vlan>(&pool, &mut failures).await;
    check_entity::<EntityTag>(&pool, &mut failures).await;
    check_entity::<DependencyMemberRecord>(&pool, &mut failures).await;
    check_entity::<SubnetVlanRecord>(&pool, &mut failures).await;

    if !failures.is_empty() {
        panic!(
            "Entity column / live-schema drift detected:\n  - {}",
            failures.join("\n  - ")
        );
    }
}

// ============================================================================
// DB-backed enum backward-compat tests
// ============================================================================

#[allow(dead_code)]
const DB_ENUM_BASELINE_PATH: &str = "tests/fixtures/db_enum_baseline.json";

#[allow(dead_code)]
fn load_db_enum_baseline() -> std::collections::BTreeMap<String, Vec<String>> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(DB_ENUM_BASELINE_PATH);
    let body = std::fs::read_to_string(&path).unwrap_or_else(|e| {
        panic!("could not read baseline fixture at {:?}: {}", path, e);
    });
    serde_json::from_str(&body).unwrap_or_else(|e| {
        panic!("baseline fixture at {:?} is not valid JSON: {}", path, e);
    })
}

/// Forward-compat: every variant the previous release could emit must still
/// deserialize into the current binary's type (directly or via a
/// `#[serde(alias)]`). Catches rename-without-alias and variant-removal.
///
/// With a variant-names baseline, "still deserializes" is checked as "name is
/// still a known variant" via `strum::VariantNames` on the current enum. If an
/// alias covers the rename, the baseline can be extended manually to include
/// the old name and regeneration will preserve it (regen warns on any name in
/// the current fixture that isn't a current-binary variant).
#[test]
fn test_current_reads_previous_release_variants() {
    use crate::server::shared::storage::traits::SqlValue;

    let baseline = load_db_enum_baseline();
    if baseline.is_empty() {
        // Fresh checkout with bootstrap fixture: nothing to compare yet. First
        // regeneration fills in the baseline; from that point on this test has
        // something to assert against.
        return;
    }

    let current = SqlValue::collect_all_db_enum_variants();

    let mut missing: Vec<String> = Vec::new();
    for (enum_name, baseline_variants) in &baseline {
        let current_variants: Option<&Vec<String>> = current.get(enum_name.as_str());
        let current_set: std::collections::HashSet<&str> = current_variants
            .into_iter()
            .flat_map(|v| v.iter().map(|s| s.as_str()))
            .collect();
        for variant in baseline_variants {
            if !current_set.contains(variant.as_str()) {
                missing.push(format!("{}::{}", enum_name, variant));
            }
        }
    }

    if !missing.is_empty() {
        panic!(
            "DB-backed enum forward-compat broken. The current binary has lost \
             variants that the previous release could emit. Rows written by the \
             previous binary will fail to deserialize in the new binary.\n\n\
             Missing variants:\n  - {}\n\n\
             Fix: either (a) restore the variant, (b) add `#[serde(alias = \"{}\")]` \
             mapping the old name to a current variant and add the alias to \
             `db_enum_baseline.json` manually, or (c) if this is an intentional \
             breaking rename coordinated with a data migration, regenerate the \
             baseline (cargo test --lib regenerate_db_enum_baseline -- --ignored) \
             and declare `Deploy-Mode: downtime` for the release.",
            missing.join("\n  - "),
            missing
                .first()
                .and_then(|s| s.rsplit(':').next())
                .unwrap_or("")
        );
    }
}

/// Backward-compat (deploy-window coexistence): the current binary must not be
/// able to emit any variant the previous release's binary can't read. If it
/// does, the old binary panics the moment the new binary writes that variant
/// to the DB.
#[test]
fn test_current_writes_subset_of_previous_release() {
    use crate::server::shared::storage::traits::SqlValue;

    let baseline = load_db_enum_baseline();
    if baseline.is_empty() {
        return; // Fresh bootstrap — see test_current_reads note above.
    }

    let current = SqlValue::collect_all_db_enum_variants();

    let mut added: Vec<String> = Vec::new();
    for (enum_name, current_variants) in &current {
        let baseline_variants: Option<&Vec<String>> = baseline.get(*enum_name);
        let baseline_set: std::collections::HashSet<&str> = baseline_variants
            .into_iter()
            .flat_map(|v| v.iter().map(|s| s.as_str()))
            .collect();
        for variant in current_variants {
            if !baseline_set.contains(variant.as_str()) {
                added.push(format!("{}::{}", enum_name, variant));
            }
        }
    }

    if !added.is_empty() {
        panic!(
            "DB-backed enum backward-compat broken. The current binary can emit \
             variants the previous release's binary can't read. If anything \
             writes these to the DB during the deploy coexistence window, the \
             old binary panics reading them.\n\n\
             Added variants:\n  - {}\n\n\
             Fix: either (a) ensure no code path writes this variant until a \
             subsequent release, (b) ship an intermediate release that teaches \
             old binaries to tolerate the new variant (via `#[serde(alias)]` or \
             a fallback) and regenerate the baseline, or (c) declare \
             `Deploy-Mode: downtime` in the release notes — the CI harness \
             skips this test and the image is labeled for stop-migrate-start \
             deploy semantics.",
            added.join("\n  - ")
        );
    }
}

/// Regenerate `db_enum_baseline.json` from the current binary's DB-backed
/// enums. Run this after cutting a release so the next cycle's coexistence
/// checks compare against the released binary. Opt-in:
///
///   cargo test --lib regenerate_db_enum_baseline -- --ignored
#[test]
#[ignore]
fn regenerate_db_enum_baseline() {
    use crate::server::shared::storage::traits::SqlValue;

    let current = SqlValue::collect_all_db_enum_variants();
    // Convert to BTreeMap<String, Vec<String>> for deterministic JSON output.
    let normalized: std::collections::BTreeMap<String, Vec<String>> = current
        .into_iter()
        .map(|(k, v)| (k.to_string(), v))
        .collect();

    let body =
        serde_json::to_string_pretty(&normalized).expect("baseline map must serialize to JSON");
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(DB_ENUM_BASELINE_PATH);
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).expect("create fixture dir");
    }
    std::fs::write(&path, format!("{}\n", body)).expect("write baseline fixture");
    println!("Regenerated DB-enum baseline at {:?}", path);
    println!("{} enums catalogued:", normalized.len());
    for (enum_name, variants) in &normalized {
        println!("  {}: {} variants", enum_name, variants.len());
    }
}
