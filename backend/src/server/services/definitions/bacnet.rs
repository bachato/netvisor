use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct BACnet;

impl ServiceDefinition for BACnet {
    fn name(&self) -> &'static str {
        "BACnet"
    }
    fn description(&self) -> &'static str {
        "Building automation and control network protocol"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::BACnet)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<BACnet>));
