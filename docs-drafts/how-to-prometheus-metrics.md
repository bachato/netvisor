# How to export metrics to Prometheus

This guide shows how to configure Prometheus or Grafana Alloy to scrape metrics from Scanopy.

## Prerequisites

- Scanopy server running
- Prometheus 2.47+ or Grafana Alloy installed

## Configure Scanopy

Set the metrics token in your Scanopy environment:

```bash
SCANOPY_METRICS_TOKEN=your-secure-token-here
```

To restrict access to specific IPs or networks:

```bash
SCANOPY_EXTERNAL_SERVICE_PROMETHEUS_ALLOWED_IPS=192.168.1.0/24,10.0.0.1
```

Restart Scanopy after changing environment variables.

## Configure Prometheus

Add a scrape job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'scanopy'
    metrics_path: /api/metrics
    static_configs:
      - targets: ['scanopy.example.com:60072']
    authorization:
      type: Bearer
      credentials: your-secure-token-here
    http_headers:
      X-Service-Name:
        values: [prometheus]
```

For HTTPS with a self-signed certificate, add `scheme` and `tls_config`:

```yaml
scrape_configs:
  - job_name: 'scanopy'
    metrics_path: /api/metrics
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ['scanopy.example.com:60072']
    authorization:
      type: Bearer
      credentials: your-secure-token-here
    http_headers:
      X-Service-Name:
        values: [prometheus]
```

## Configure Grafana Alloy

Add a `prometheus.scrape` component to your Alloy configuration:

```alloy
prometheus.scrape "scanopy" {
  targets = [{
    __address__ = "scanopy.example.com:60072",
  }]

  forward_to      = [prometheus.remote_write.default.receiver]
  metrics_path    = "/api/metrics"

  authorization {
    type        = "Bearer"
    credentials = "your-secure-token-here"
  }

  extra_headers = {
    "X-Service-Name" = "prometheus",
  }
}
```

For HTTPS with a self-signed certificate:

```alloy
prometheus.scrape "scanopy" {
  targets = [{
    __address__ = "scanopy.example.com:60072",
  }]

  forward_to      = [prometheus.remote_write.default.receiver]
  scheme          = "https"
  metrics_path    = "/api/metrics"

  tls_config {
    insecure_skip_verify = true
  }

  authorization {
    type        = "Bearer"
    credentials = "your-secure-token-here"
  }

  extra_headers = {
    "X-Service-Name" = "prometheus",
  }
}
```

## Verify the connection

Check that metrics are being scraped:

**Prometheus:** Navigate to Status > Targets and confirm the `scanopy` target shows "UP".

**Grafana Alloy:** Check the Alloy UI or logs for successful scrape messages.

Test manually with curl:

```bash
curl -H "Authorization: Bearer your-secure-token-here" \
     -H "X-Service-Name: prometheus" \
     https://scanopy.example.com:60072/api/metrics
```
