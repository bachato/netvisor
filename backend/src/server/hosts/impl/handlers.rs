use crate::server::{
    config::AppState,
    hosts::{r#impl::base::Host, service::HostService},
    shared::{
        entities::EntityDiscriminants,
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        taggable::Taggable,
        types::entities::EntitySource,
    },
};
use uuid::Uuid;

impl Taggable for Host {
    fn entity_type() -> &'static str {
        "Host"
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

impl CrudHandlers for Host {
    type Service = HostService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.host_service
    }

    fn set_source(&mut self, source: EntitySource) {
        self.base.source = source;
    }

    fn preserve_immutable_fields(&mut self, existing: &Self) {
        // source is set at creation time (Manual or Discovery), cannot be changed
        self.base.source = existing.base.source.clone();
    }

    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        Some(&self.base.tags)
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }

    fn tag_entity_type() -> Option<EntityDiscriminants> {
        Some(EntityDiscriminants::Host)
    }
}
