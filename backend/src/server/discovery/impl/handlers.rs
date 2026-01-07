use crate::server::{
    config::AppState,
    discovery::{r#impl::base::Discovery, service::DiscoveryService},
    shared::{
        entities::EntityDiscriminants,
        handlers::{query::DiscoveryQuery, traits::CrudHandlers},
        taggable::Taggable,
    },
};
use uuid::Uuid;

impl Taggable for Discovery {
    fn entity_type() -> &'static str {
        "Discovery"
    }

    fn id(&self) -> Uuid {
        self.id
    }

    fn tags(&self) -> &[Uuid] {
        &self.base.tags
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }
}

impl CrudHandlers for Discovery {
    type Service = DiscoveryService;
    type FilterQuery = DiscoveryQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.discovery_service
    }

    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        Some(&self.base.tags)
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }

    fn tag_entity_type() -> Option<EntityDiscriminants> {
        Some(EntityDiscriminants::Discovery)
    }
}
