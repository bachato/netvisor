use super::{
    application_builder::ApplicationBuilder, context::TopologyContext,
    infrastructure_builder::InfrastructureBuilder, l3_builder::L3Builder,
};
use crate::server::topology::types::{
    edges::Edge, grouping::GroupingConfig, nodes::Node, views::TopologyView,
};

pub trait ViewBuilder {
    fn build(&self, ctx: &TopologyContext, grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>);
}

pub fn builder_for_view(view: TopologyView) -> Box<dyn ViewBuilder> {
    match view {
        TopologyView::L3Logical => Box::new(L3Builder),
        TopologyView::Application => Box::new(ApplicationBuilder),
        TopologyView::Infrastructure => Box::new(InfrastructureBuilder),
        // L2Physical will have its own builder; fall back to L3 for now
        _ => Box::new(L3Builder),
    }
}
