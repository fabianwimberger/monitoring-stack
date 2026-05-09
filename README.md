# Monitoring Stack

[![CI](https://github.com/fabianwimberger/monitoring-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/fabianwimberger/monitoring-stack/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Docker Compose monitoring stack for self-hosted infrastructure. Metrics, logs, dashboards, and uptime monitoring in one command.

- **Metrics** — Prometheus + cAdvisor + node_exporter
- **Logs** — Loki + Grafana Alloy (Docker containers + systemd journal)
- **Dashboards** — Grafana with pre-provisioned dashboards
- **Uptime** — Uptime Kuma for endpoint monitoring

## Background

I kept setting up the same Prometheus, Grafana, and Loki combination on every
self-hosted box. This is that stack packaged as one command, with the pieces I
actually use: cAdvisor and node_exporter for metrics, Alloy for Docker and
systemd-journal logs, Uptime Kuma for endpoint checks, and Grafana with
dashboards already wired up.

### Companion projects

This stack is the dashboard layer. Two of my other repos plug straight into it
as data sources:

| Repo | What it provides | How this stack uses it |
|---|---|---|
| [openwrt-only-home-network](https://github.com/fabianwimberger/openwrt-only-home-network) | Whole-home OpenWrt WiFi blueprint (wired APs + WDS repeaters) | Each node runs `node_exporter`; this stack scrapes them and visualizes them in the bundled OpenWrt WiFi dashboard |
| [fritzbox-monitoring](https://github.com/fabianwimberger/fritzbox-monitoring) | Prometheus exporter for AVM FritzBox cable modems (DOCSIS, speeds, ping) | Add its `:8000` target to `prometheus.yml` and import its Grafana dashboard |

Neither is required — the stack works standalone — but if you run them, the
integration is just a scrape-config edit.

## Architecture

```mermaid
flowchart LR
    subgraph Host
        node[node_exporter]
        cadvisor[cAdvisor]
        journal[systemd journal]
        docker[Docker logs]
    end

    subgraph Monitoring
        prom[Prometheus]
        loki[Loki]
        alloy[Alloy]
        grafana[Grafana]
        kuma[Uptime Kuma]
    end

    node --> prom
    cadvisor --> prom
    docker --> alloy --> loki
    journal --> alloy
    prom --> grafana
    loki --> grafana
```

## Quick Start

### Option 1: Local / LAN

For testing or running on your local network with direct port access:

```bash
git clone https://github.com/fabianwimberger/monitoring-stack.git
cd monitoring-stack

# Optional: edit settings
cp .env.example .env

# Start
make up
```

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Uptime Kuma | http://localhost:3001 |

Default Grafana login: `admin` / `changeme` (set `GRAFANA_ADMIN_PASSWORD` in `.env` to change).

### Option 2: Behind a Reverse Proxy

If you run [Traefik](https://traefik.io/) (or similar) already, use the proxy overlay:

```bash
cp .env.example .env
# Edit .env and set your domains:
#   GRAFANA_DOMAIN=grafana.example.com
#   UPTIME_KUMA_DOMAIN=uptime.example.com

make up-proxy
```

This exposes **only** Grafana and Uptime Kuma via your reverse proxy. Prometheus, Loki, Alloy, and cAdvisor stay on an isolated internal network with no public access.

See `docker-compose.proxy.yml` if you use a different proxy — the labels are easy to adapt.

## Network Isolation

The compose setup uses two networks:

- **`monitoring`** — internal communication between Prometheus, Loki, Alloy, and cAdvisor
- **`proxy`** — for services that need external access (Grafana, Uptime Kuma)

In proxy mode, backend services have no exposed ports and no route from the outside. Grafana and Uptime Kuma are the only entrypoints.

## Screenshots

<p align="center">
  <img src="assets/host-dashboard.png" width="100%" alt="Host monitoring dashboard">
  <br><em>Host monitoring dashboard — CPU, memory, disk, network</em>
</p>

<p align="center">
  <img src="assets/log-explorer.png" width="100%" alt="Log explorer">
  <br><em>Log explorer — search across Docker containers and systemd journal</em>
</p>

<p align="center">
  <img src="assets/cadvisor.png" width="100%" alt="cAdvisor container metrics">
  <br><em>cAdvisor container metrics — per-container CPU, memory, network, and disk I/O</em>
</p>

<p align="center">
  <img src="assets/openwrt-wifi-overview.png" width="100%" alt="OpenWrt WiFi overview">
  <br><em>OpenWrt WiFi dashboard — per-AP status, client counts, backhaul signal, CPU/RAM, stations per AP, per-client signal</em>
</p>

<p align="center">
  <img src="assets/openwrt-wifi-backhaul.png" width="100%" alt="OpenWrt WiFi backhaul and system metrics">
  <br><em>OpenWrt WiFi dashboard — backhaul signal, bitrate and quality, plus per-node system and network metrics</em>
</p>

## Configuration

All settings are via `.env` (see [`.env.example`](.env.example)):

| Variable | Default | Description |
|---|---|---|
| `TZ` | `UTC` | Timezone for all services |
| `PROMETHEUS_PORT` | `9090` | Prometheus web UI port (local mode) |
| `PROMETHEUS_RETENTION` | `30d` | Metrics retention |
| `GRAFANA_PORT` | `3000` | Grafana web UI port (local mode) |
| `GRAFANA_ADMIN_PASSWORD` | `changeme` | Grafana admin password |
| `UPTIME_KUMA_PORT` | `3001` | Uptime Kuma web UI port (local mode) |
| `GRAFANA_DOMAIN` | — | Domain for Grafana (proxy mode) |
| `UPTIME_KUMA_DOMAIN` | — | Domain for Uptime Kuma (proxy mode) |
| `PROXY_NETWORK` | `proxy` | Name of your external Docker proxy network |

Metrics are retained for 30 days by default. Logs are retained for 14 days in
`config/loki.yml` because they usually use more disk space than metrics.

### Adding Hosts to Monitor

Edit `config/prometheus.yml` and add your `node_exporter` instances:

```yaml
scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ["192.168.1.10:9100", "192.168.1.11:9100"]
```

The bundled `dashboards/openwrt-wifi-network.json` expects an `openwrt` job
with a `node` label per device — see the commented template in
`config/prometheus.yml`.

### Adding Dashboards

Drop Grafana dashboard JSON files into `dashboards/`. They are auto-provisioned on startup.

### Backup and Restore

The stack stores data in named Docker volumes. Back up the volumes before
upgrades or host moves:

```bash
docker run --rm \
  -v monitoring-stack_prometheus-data:/prometheus:ro \
  -v monitoring-stack_grafana-data:/grafana:ro \
  -v monitoring-stack_loki-data:/loki:ro \
  -v monitoring-stack_alloy-data:/alloy:ro \
  -v monitoring-stack_uptime-kuma-data:/uptime-kuma:ro \
  -v "$PWD/backups":/backup \
  alpine tar czf /backup/monitoring-stack-volumes.tgz \
    prometheus grafana loki alloy uptime-kuma
```

Restore into an empty stack:

```bash
docker run --rm \
  -v monitoring-stack_prometheus-data:/prometheus \
  -v monitoring-stack_grafana-data:/grafana \
  -v monitoring-stack_loki-data:/loki \
  -v monitoring-stack_alloy-data:/alloy \
  -v monitoring-stack_uptime-kuma-data:/uptime-kuma \
  -v "$PWD/backups":/backup:ro \
  alpine tar xzf /backup/monitoring-stack-volumes.tgz -C /
```

## Requirements

- Docker and Docker Compose v2
- Linux host (for systemd journal and cAdvisor access)
- [node_exporter](https://github.com/prometheus/node_exporter) installed on hosts you want to monitor
- For proxy mode: an existing reverse proxy (Traefik, Nginx, Caddy, etc.)

## Makefile Commands

| Command | Description |
|---|---|
| `make up` | Start stack (local mode) |
| `make down` | Stop stack |
| `make restart` | Restart all services |
| `make logs` | Follow logs |
| `make clean` | Stop and remove all volumes (**deletes data**) |
| `make up-proxy` | Start stack behind reverse proxy |
| `make down-proxy` | Stop proxy stack |

## Security Notes

- **Alloy** runs with access to the Docker socket and systemd journal. The container uses `group_add` with `DOCKER_GID` (set in `.env`) so the process can access the Docker socket without full root privileges, and `cap_add: [DAC_READ_SEARCH]` helps with journal access. If you want to run fully unprivileged, set `DOCKER_GID` to your host's docker group ID and override the user in `docker-compose.yml`.
- **cAdvisor** runs `privileged: true` to read host hardware metrics. This is required by cAdvisor's design.
- All services include log rotation (`max-size: 10m`, `max-file: 3`) to prevent unbounded disk growth.

## License

[MIT](LICENSE)
