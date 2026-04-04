use super::{
    application_builder::ApplicationBuilder, context::TopologyContext, l3_builder::L3Builder,
};
use crate::server::topology::types::{
    edges::{Edge, TopologyPerspective},
    grouping::GroupingConfig,
    nodes::Node,
};

pub trait PerspectiveBuilder {
    fn build(&self, ctx: &TopologyContext, grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>);
}

pub fn builder_for_perspective(perspective: TopologyPerspective) -> Box<dyn PerspectiveBuilder> {
    match perspective {
        TopologyPerspective::L3Logical => Box::new(L3Builder),
        TopologyPerspective::Application => Box::new(ApplicationBuilder),
        // Future perspectives will have their own builders
        _ => Box::new(L3Builder),
    }
}
