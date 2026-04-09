use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    shared::{
        entities::EntityDiscriminants,
        entity_metadata::EntityCategory,
        storage::traits::{Entity, SqlValue, Storable},
    },
    vlans::r#impl::base::{Vlan, VlanBase},
};

/// CSV row representation for Vlan export
#[derive(Serialize)]
pub struct VlanCsvRow {
    pub id: Uuid,
    pub vlan_number: u16,
    pub name: String,
    pub description: Option<String>,
    pub network_id: Uuid,
    pub organization_id: Uuid,
    pub source: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl Storable for Vlan {
    type BaseData = VlanBase;

    fn table_name() -> &'static str {
        "vlans"
    }

    fn new(base: Self::BaseData) -> Self {
        let now = chrono::Utc::now();

        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>), anyhow::Error> {
        let Self {
            id,
            created_at,
            updated_at,
            base:
                Self::BaseData {
                    vlan_number,
                    name,
                    description,
                    network_id,
                    organization_id,
                    source,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "vlan_number",
                "name",
                "description",
                "network_id",
                "organization_id",
                "source",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::U16(vlan_number),
                SqlValue::String(name),
                SqlValue::OptionalString(description),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(organization_id),
                SqlValue::EntitySource(source),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let vlan_number_i16: i16 = row.get("vlan_number");
        Ok(Vlan {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: VlanBase {
                vlan_number: vlan_number_i16 as u16,
                name: row.get("name"),
                description: row.get("description"),
                network_id: row.get("network_id"),
                organization_id: row.get("organization_id"),
                source: serde_json::from_value(row.get::<serde_json::Value, _>("source"))
                    .map_err(|e| anyhow::anyhow!("Failed to deserialize source: {}", e))?,
            },
        })
    }
}

impl Entity for Vlan {
    fn id(&self) -> Uuid {
        self.id
    }

    fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }

    fn set_id(&mut self, id: Uuid) {
        self.id = id;
    }

    fn set_created_at(&mut self, time: DateTime<Utc>) {
        self.created_at = time;
    }

    type CsvRow = VlanCsvRow;

    fn to_csv_row(&self) -> Self::CsvRow {
        VlanCsvRow {
            id: self.id,
            vlan_number: self.base.vlan_number,
            name: self.base.name.clone(),
            description: self.base.description.clone(),
            network_id: self.base.network_id,
            organization_id: self.base.organization_id,
            source: serde_json::to_string(&self.base.source).unwrap_or_default(),
            created_at: self.created_at,
            updated_at: self.updated_at,
        }
    }

    fn entity_type() -> EntityDiscriminants {
        EntityDiscriminants::Vlan
    }

    const ENTITY_NAME_SINGULAR: &'static str = "Vlan";
    const ENTITY_NAME_PLURAL: &'static str = "Vlans";
    const ENTITY_DESCRIPTION: &'static str = "Virtual LANs discovered from network switches. VLANs segment network traffic and are associated with interfaces and subnets.";

    fn entity_category() -> EntityCategory {
        EntityCategory::NetworkInfrastructure
    }

    fn network_id(&self) -> Option<Uuid> {
        Some(self.base.network_id)
    }

    fn organization_id(&self) -> Option<Uuid> {
        Some(self.base.organization_id)
    }

    fn updated_at(&self) -> DateTime<Utc> {
        self.updated_at
    }

    fn set_updated_at(&mut self, time: DateTime<Utc>) {
        self.updated_at = time;
    }
}
