use metrics_exporter_prometheus::PrometheusHandle;

#[derive(Clone)]
pub struct MetricsService {
    pub handle: PrometheusHandle,
}

impl MetricsService {
    pub fn new(handle: PrometheusHandle) -> Self {
        Self { handle }
    }
}
