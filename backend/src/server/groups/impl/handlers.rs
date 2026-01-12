use crate::server::{
    config::AppState,
    groups::{handlers::GroupFilterQuery, r#impl::base::Group, service::GroupService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Group {
    type Service = GroupService;
    type FilterQuery = GroupFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.group_service
    }
}
