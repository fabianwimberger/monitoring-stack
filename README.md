# Monitoring Stack

[![CI](https://github.com/fabianwimberger/monitoring-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/fabianwimberger/monitoring-stack/actions)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A batteries-included Docker Compose monitoring stack for self-hosted infrastructure.

- **Metrics** — Prometheus + cAdvisor + node_exporter
- **Logs** — Loki + Grafana Alloy (Docker containers + systemd journal)
- **Dashboards** — Grafana with pre-provisioned dashboards
- **Uptime** — Uptime Kuma for endpoint monitoring

## Why This Project?

Setting up monitoring for a homelab or small server typically means stitching together multiple guides, debugging config file formats, and wiring services together manually. This project provides a single `docker compose up` that gives you a fully integrated monitoring stack with sensible defaults.

**Goals:**
- Single-command deployment with zero mandatory configuration
- Cover the three pillars of observability: metrics, logs, and uptime
- Pre-configured dashboards so you get value immediately
- Easy to extend with additional scrape targets and exporters

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌────────────┐
│ node_exporter│────▶│  Prometheus  │────▶│            │
└─────────────┘     └──────────────┘     │            │
┌─────────────┐            │             │  Grafana   │
│  cAdvisor   │────────────┘             │            │
└─────────────┘                          │            │
┌─────────────┐     ┌──────────────┐     │            │
│Docker + syslog────▶│ Alloy → Loki │────▶│            │
└─────────────┘     └──────────────┘     └────────────┘
┌─────────────┐
│ Uptime Kuma │  (standalone uptime/status page)
└─────────────┘
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/fabianwimberger/monitoring-stack.git
cd monitoring-stack

# (Optional) Customize settings
cp .env.example .env

# Start the stack
make up
```

Access the services:

| Service | URL |
|---|---|
| Grafana | [http://localhost:3000](http://localhost:3000) |
| Prometheus | [http://localhost:9090](http://localhost:9090) |
| Uptime Kuma | [http://localhost:3001](http://localhost:3001) |

Default Grafana credentials: `admin` / `admin`

## Configuration

All settings can be customized via `.env` (see [`.env.example`](.env.example)):

| Variable | Default | Description |
|---|---|---|
| `TZ` | `UTC` | Timezone for all services |
| `PROMETHEUS_PORT` | `9090` | Prometheus web UI port |
| `PROMETHEUS_RETENTION` | `30d` | How long to keep metrics |
| `GRAFANA_PORT` | `3000` | Grafana web UI port |
| `UPTIME_KUMA_PORT` | `3001` | Uptime Kuma web UI port |

### Adding Prometheus Scrape Targets

Edit `config/prometheus.yml` and add targets under `scrape_configs`:

```yaml
scrape_configs:
  - job_name: "my-app"
    static_configs:
      - targets: ["my-app-host:8080"]
```

### Adding More Dashboards

Drop Grafana dashboard JSON files into `dashboards/`. They are auto-provisioned on startup.

## Services

| Service | Purpose |
|---|---|
| **Prometheus** | Metrics collection and storage |
| **Grafana** | Visualization and dashboards |
| **Loki** | Log aggregation |
| **Alloy** | Log collection agent (Docker + systemd) |
| **cAdvisor** | Container resource metrics |
| **Uptime Kuma** | Uptime monitoring and status pages |

## Requirements

- Docker and Docker Compose v2
- Linux host (for systemd journal and cAdvisor access)
- [node_exporter](https://github.com/prometheus/node_exporter) installed on hosts you want to monitor

## License

[MIT](LICENSE)
