use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct UbiquitiDiscovery;

impl ServiceDefinition for UbiquitiDiscovery {
    fn name(&self) -> &'static str {
        "Ubiquiti Discovery"
    }
    fn description(&self) -> &'static str {
        "Ubiquiti device discovery service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::UBIQUITI),
            Pattern::Port(PortType::new_udp(10001)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ubiquiti.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<UbiquitiDiscovery>
));
