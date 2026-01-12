use crate::server::{
    config::AppState,
    shared::handlers::traits::CrudHandlers,
    tags::{handlers::TagFilterQuery, r#impl::base::Tag, service::TagService},
};

impl CrudHandlers for Tag {
    type Service = TagService;
    type FilterQuery = TagFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.tag_service
    }
}
