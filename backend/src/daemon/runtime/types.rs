use std::{net::IpAddr, sync::Arc};

use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::daemon::{
    shared::{config::ConfigStore, services::DaemonServiceFactory},
    utils::base::{DaemonUtils, PlatformDaemonUtils},
};

#[derive(Serialize, Deserialize)]
pub struct InitializeDaemonRequest {
    pub network_id: Uuid,
    pub api_key: String,
}

pub struct DaemonAppState {
    pub config: Arc<ConfigStore>,
    pub services: Arc<DaemonServiceFactory>,
    pub utils: PlatformDaemonUtils,
}

impl DaemonAppState {
    pub async fn new(
        config: Arc<ConfigStore>,
        utils: PlatformDaemonUtils,
    ) -> anyhow::Result<Arc<Self>> {
        config.initialize().await?;

        // Compute daemon URL for use in status responses
        let daemon_url = Self::compute_daemon_url(&config, &utils).await?;

        let services = Arc::new(DaemonServiceFactory::new(config.clone(), daemon_url).await?);
        Ok(Arc::new(Self {
            config,
            services,
            utils,
        }))
    }

    /// Compute the daemon's public URL based on config and network settings.
    async fn compute_daemon_url(
        config: &ConfigStore,
        utils: &PlatformDaemonUtils,
    ) -> anyhow::Result<String> {
        if let Some(daemon_url) = config.get_daemon_url().await? {
            Ok(daemon_url)
        } else {
            let bind_address = config.get_bind_address().await?;
            let daemon_ip = if bind_address == "0.0.0.0" || bind_address == "::" {
                utils.get_own_ip_address()?
            } else {
                bind_address.parse::<IpAddr>()?
            };
            let daemon_port = config.get_port().await?;
            Ok(format!("http://{}:{}", daemon_ip, daemon_port))
        }
    }
}
