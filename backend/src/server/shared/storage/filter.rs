use std::marker::PhantomData;

use chrono::{DateTime, Utc};
use email_address::EmailAddress;
use mac_address::MacAddress;
use uuid::Uuid;

use crate::server::{
    shared::{entities::EntityDiscriminants, storage::traits::SqlValue},
    users::r#impl::permissions::UserOrgPermissions,
};

use super::traits::Storable;

/// Builder pattern for common WHERE clauses with optional pagination and JOINs.
/// Generic over entity type T to automatically qualify column names with the table name.
#[derive(Clone)]
pub struct StorableFilter<T: Storable> {
    _marker: PhantomData<T>,
    conditions: Vec<String>,
    values: Vec<SqlValue>,
    limit_value: Option<u32>,
    offset_value: Option<u32>,
    joins: Vec<String>,
}

impl<T: Storable> Default for StorableFilter<T> {
    fn default() -> Self {
        Self::new()
    }
}

impl<T: Storable> StorableFilter<T> {
    pub fn new() -> Self {
        Self {
            _marker: PhantomData,
            conditions: Vec::new(),
            values: Vec::new(),
            limit_value: None,
            offset_value: None,
            joins: Vec::new(),
        }
    }

    /// Qualify a column name with the table name.
    fn qualify_column(&self, column: &str) -> String {
        format!("{}.{}", T::table_name(), column)
    }

    /// Set the maximum number of results to return.
    pub fn limit(mut self, limit: u32) -> Self {
        self.limit_value = Some(limit);
        self
    }

    /// Set the number of results to skip.
    pub fn offset(mut self, offset: u32) -> Self {
        self.offset_value = Some(offset);
        self
    }

    /// Get the limit value, if set.
    pub fn get_limit(&self) -> Option<u32> {
        self.limit_value
    }

    /// Get the offset value, if set.
    pub fn get_offset(&self) -> Option<u32> {
        self.offset_value
    }

    /// Generate LIMIT clause if limit is set.
    pub fn to_limit_clause(&self) -> String {
        match self.limit_value {
            Some(limit) => format!("LIMIT {}", limit),
            None => String::new(),
        }
    }

    /// Generate OFFSET clause if offset is set.
    pub fn to_offset_clause(&self) -> String {
        match self.offset_value {
            Some(offset) if offset > 0 => format!("OFFSET {}", offset),
            _ => String::new(),
        }
    }

    /// Generate combined LIMIT and OFFSET clause.
    pub fn to_pagination_clause(&self) -> String {
        let mut parts = Vec::new();
        if let Some(limit) = self.limit_value {
            parts.push(format!("LIMIT {}", limit));
        }
        if let Some(offset) = self.offset_value
            && offset > 0
        {
            parts.push(format!("OFFSET {}", offset));
        }
        parts.join(" ")
    }

    /// Add a JOIN clause to the filter.
    /// Example: `filter.join("LEFT JOIN services AS s ON hosts.service_id = s.id")`
    pub fn join(mut self, join_clause: &str) -> Self {
        self.joins.push(join_clause.to_string());
        self
    }

    /// Generate the combined JOIN clause string.
    pub fn to_join_clause(&self) -> String {
        self.joins.join(" ")
    }

    /// Returns true if this filter has any JOIN clauses.
    pub fn has_joins(&self) -> bool {
        !self.joins.is_empty()
    }

    pub fn entity_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn entity_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let col = self.qualify_column("id");
        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", col, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn network_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let col = self.qualify_column("network_id");
        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", col, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn user_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("user_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn hidden_is(mut self, hidden: bool) -> Self {
        let col = self.qualify_column("hidden");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Bool(hidden));
        self
    }

    pub fn host_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("host_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn subnet_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("subnet_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn mac_address(mut self, mac: &MacAddress) -> Self {
        let col = self.qualify_column("mac_address");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::MacAddress(*mac));
        self
    }

    pub fn name(mut self, name: String) -> Self {
        let col = self.qualify_column("name");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::String(name));
        self
    }

    pub fn group_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("group_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn group_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let col = self.qualify_column("group_id");
        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", col, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn binding_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("binding_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn host_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let col = self.qualify_column("host_id");
        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", col, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn api_key(mut self, api_key: String) -> Self {
        let col = self.qualify_column("key");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::String(api_key));
        self
    }

    pub fn scheduled_discovery(mut self) -> Self {
        self.conditions
            .push("run_type->>'type' = 'Scheduled'".to_string());
        self.conditions
            .push("(run_type->>'enabled')::boolean = true".to_string());
        self
    }

    pub fn oidc_subject(mut self, subject: String) -> Self {
        let col = self.qualify_column("oidc_subject");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::String(subject));
        let provider_col = self.qualify_column("oidc_provider");
        self.conditions
            .push(format!("{} IS NOT NULL", provider_col));
        self
    }

    pub fn email(mut self, email: &EmailAddress) -> Self {
        let col = self.qualify_column("email");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Email(email.clone()));
        self
    }

    pub fn organization_id(mut self, organization_id: &Uuid) -> Self {
        let col = self.qualify_column("organization_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*organization_id));
        self
    }

    pub fn topology_id(mut self, topology_id: &Uuid) -> Self {
        let col = self.qualify_column("topology_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*topology_id));
        self
    }

    pub fn user_permissions(mut self, permissions: &UserOrgPermissions) -> Self {
        let col = self.qualify_column("permissions");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::UserOrgPermissions(*permissions));
        self
    }

    pub fn expires_before(mut self, timestamp: DateTime<Utc>) -> Self {
        let col = self.qualify_column("expires_at");
        self.conditions
            .push(format!("{} < ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Timestamp(timestamp));
        self
    }

    /// Generic UUID filter for any column name.
    /// Used by generic child entity handlers to filter by parent_column dynamically.
    pub fn uuid_column(mut self, column: &str, id: &Uuid) -> Self {
        let col = self.qualify_column(column);
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    /// Generic UUID IN filter for any column name.
    /// Used by generic child entity services to filter by parent_column dynamically.
    pub fn uuid_columns(mut self, column: &str, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let col = self.qualify_column(column);
        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", col, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    /// Filter by service_id (for bindings)
    pub fn service_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("service_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    /// Filter by entity_type (for entity_tags junction table)
    pub fn entity_type(mut self, entity_type: &EntityDiscriminants) -> Self {
        let col = self.qualify_column("entity_type");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        // Use EntityDiscriminant to match JSON serialization used when inserting
        self.values.push(SqlValue::EntityDiscriminant(*entity_type));
        self
    }

    /// Filter by tag_id (for entity_tags junction table)
    pub fn tag_id(mut self, id: &Uuid) -> Self {
        let col = self.qualify_column("tag_id");
        self.conditions
            .push(format!("{} = ${}", col, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    /// Filter entities that have ANY of the specified tags.
    /// Uses a subquery against the entity_tags junction table.
    ///
    /// Example SQL: `entities.id IN (SELECT entity_id FROM entity_tags WHERE entity_type = 'Service' AND tag_id IN ($1, $2))`
    pub fn has_any_tags(mut self, tag_ids: &[Uuid], entity_type: EntityDiscriminants) -> Self {
        if tag_ids.is_empty() {
            return self;
        }

        let col = self.qualify_column("id");
        let entity_type_idx = self.values.len() + 1;
        let placeholders: Vec<String> = tag_ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 2))
            .collect();

        self.conditions.push(format!(
            "{} IN (SELECT entity_id FROM entity_tags WHERE entity_type = ${} AND tag_id IN ({}))",
            col,
            entity_type_idx,
            placeholders.join(", ")
        ));

        self.values.push(SqlValue::EntityDiscriminant(entity_type));
        for id in tag_ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn to_where_clause(&self) -> String {
        if self.conditions.is_empty() {
            String::new()
        } else {
            format!("WHERE {}", self.conditions.join(" AND "))
        }
    }

    pub fn values(&self) -> &[SqlValue] {
        &self.values
    }
}
