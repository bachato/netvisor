use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::hash::Hash;
use strum_macros::{EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    hosts::r#impl::base::Host,
    shared::{
        concepts::Concept,
        types::{
            Color, Icon,
            metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
        },
    },
    topology::types::views::{HasFilterValues, MetadataFilterType},
};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, IntoStaticStr, ToSchema)]
#[schema(title = "HostVirtualization")]
#[serde(tag = "type", content = "details")]
pub enum HostVirtualization {
    #[schema(title = "Proxmox")]
    Proxmox(ProxmoxVirtualization),
}

#[derive(Debug, Clone, Serialize, Validate, Deserialize, PartialEq, Eq, Hash, ToSchema)]
pub struct ProxmoxVirtualization {
    pub vm_name: Option<String>,
    pub vm_id: Option<String>,
    pub service_id: Uuid,
}

impl HostVirtualization {
    pub fn service_id(&self) -> Option<Uuid> {
        match self {
            Self::Proxmox(p) => Some(p.service_id),
        }
    }

    pub fn set_service_id(&mut self, id: Uuid) {
        match self {
            Self::Proxmox(p) => p.service_id = id,
        }
    }
}

impl HasId for HostVirtualization {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for HostVirtualization {
    fn color(&self) -> Color {
        Concept::Virtualization.color()
    }
    fn icon(&self) -> Icon {
        Concept::Virtualization.icon()
    }
}

impl TypeMetadataProvider for HostVirtualization {
    fn name(&self) -> &'static str {
        "Proxmox"
    }

    fn description(&self) -> &'static str {
        "A host running as a Proxmox VM"
    }
}

/// Coarse virtualization state used by the `Virtualization` metadata filter
/// on Host. Each host resolves to exactly one variant via `HasFilterValues`.
/// Today derived from `host.virtualization.is_some()`; future finer states
/// (e.g. per-hypervisor) can add variants here without breaking persistence
/// of the existing ids.
#[derive(
    Debug,
    Clone,
    Copy,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
    IntoStaticStr,
    EnumIter,
    ToSchema,
)]
pub enum HostVirtualizationState {
    Virtualized,
    BareMetal,
}

impl HostVirtualizationState {
    pub fn from_host_virtualization(v: Option<&HostVirtualization>) -> Self {
        match v {
            Some(_) => Self::Virtualized,
            None => Self::BareMetal,
        }
    }
}

impl HasId for HostVirtualizationState {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for HostVirtualizationState {
    fn color(&self) -> Color {
        match self {
            Self::Virtualized => Concept::Virtualization.color(),
            Self::BareMetal => Color::Gray,
        }
    }
    fn icon(&self) -> Icon {
        match self {
            Self::Virtualized => Concept::Virtualization.icon(),
            Self::BareMetal => Icon::Server,
        }
    }
}

impl TypeMetadataProvider for HostVirtualizationState {
    fn name(&self) -> &'static str {
        match self {
            Self::Virtualized => "Virtualized",
            Self::BareMetal => "Bare metal",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Self::Virtualized => "Hosts running as virtual machines",
            Self::BareMetal => "Hosts running on physical hardware",
        }
    }
}

impl HasFilterValues for Host {
    fn filter_values(&self) -> BTreeMap<MetadataFilterType, String> {
        let mut values = BTreeMap::new();
        let state =
            HostVirtualizationState::from_host_virtualization(self.base.virtualization.as_ref());
        values.insert(MetadataFilterType::Virtualization, state.id().to_string());
        values
    }
}
