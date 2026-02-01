use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct RoborockVacuum;

impl ServiceDefinition for RoborockVacuum {
    fn name(&self) -> &'static str {
        "Roborock Vacuum"
    }
    fn description(&self) -> &'static str {
        "Roborock robot vacuum cleaner"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::ROBOROCK),
            Pattern::Port(PortType::new_tcp(58867)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.prod.website-files.com/6720fa7290112f642d0a83ac/674de5c03f0d05e27b16b2cf_roborock_logo.webp"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<RoborockVacuum>
));
