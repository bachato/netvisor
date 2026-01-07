use crate::server::{
    config::AppState,
    daemons::{r#impl::base::Daemon, service::DaemonService},
    shared::{
        entities::EntityDiscriminants,
        handlers::{query::HostChildQuery, traits::CrudHandlers},
        taggable::Taggable,
    },
};
use uuid::Uuid;

impl Taggable for Daemon {
    fn entity_type() -> &'static str {
        "Daemon"
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

impl CrudHandlers for Daemon {
    type Service = DaemonService;
    type FilterQuery = HostChildQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.daemon_service
    }

    fn preserve_immutable_fields(&mut self, existing: &Self) {
        // url is set at registration time, cannot be changed via update
        self.base.url = existing.base.url.clone();
        // last_seen is server-set only
        self.base.last_seen = existing.base.last_seen;
        // capabilities are reported by the daemon, not user-editable
        self.base.capabilities = existing.base.capabilities.clone();
    }

    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        Some(&self.base.tags)
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }

    fn tag_entity_type() -> Option<EntityDiscriminants> {
        Some(EntityDiscriminants::Daemon)
    }
}
