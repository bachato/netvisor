use super::{
    application_builder::ApplicationBuilder, context::TopologyContext,
    infrastructure_builder::InfrastructureBuilder, l2_builder::L2Builder, l3_builder::L3Builder,
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
        TopologyView::L2Physical => Box::new(L2Builder),
    }
}
