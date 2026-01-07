use uuid::Uuid;

/// Trait for entities that support tag assignments.
///
/// This trait is used by the EntityTagService to hydrate tags on entities
/// retrieved from the database. It is NOT a bound on CrudHandlers - it's only
/// required where tag operations are actually needed.
///
/// # Example
///
/// ```rust
/// impl Taggable for Host {
///     fn entity_type() -> &'static str { "Host" }
///     fn id(&self) -> Uuid { self.id }
///     fn tags(&self) -> &[Uuid] { &self.base.tags }
///     fn set_tags(&mut self, tags: Vec<Uuid>) { self.base.tags = tags; }
/// }
/// ```
pub trait Taggable {
    /// The entity type name used in the entity_tags junction table.
    /// Must match the entity_type values used in the database.
    fn entity_type() -> &'static str;

    /// Get the entity's unique identifier.
    fn id(&self) -> Uuid;

    /// Get the current tag IDs assigned to this entity.
    fn tags(&self) -> &[Uuid];

    /// Set the tag IDs for this entity (used during hydration).
    fn set_tags(&mut self, tags: Vec<Uuid>);
}
