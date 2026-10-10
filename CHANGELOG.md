# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.3.5] - 2026-10-03

Updates Prometheus and Alloy and keeps configuration checks aligned with the selected container versions.

### Fixes

- Replace the deprecated Alloy environment lookup with `sys.env`.
- Validate Prometheus and Alloy configurations with the versions selected in Compose.
- Run YAML linting in a virtual environment.

### Dependencies

- Update Prometheus from 3.14.0 to 3.15.0.
- Update Grafana Alloy from 1.19.2 to 1.20.1.
- Pin yamllint to 1.38.0 and track its updates through Dependabot.

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.3.4] - 2026-10-02

Updates Grafana to 13.2.3 using the maintained Docker image repository.

### Dependencies

- Switch from `grafana/grafana-oss:13.0.2` to `grafana/grafana:13.2.3`

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.3.3] - 2026-10-02

Updates the pinned Loki, cAdvisor, and Uptime Kuma images.

### Dependencies

- Bump Loki from 3.7.7 to 3.7.8
- Bump cAdvisor from v0.60.5 to v0.60.6
- Bump Uptime Kuma from 2.5.4 to 2.5.5

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.3.2] - 2026-09-19

Updates the pinned monitoring stack images and validates the Prometheus configuration in CI.

### Features

- Validate the Prometheus configuration and dashboards in CI, and run the checks on pull requests to develop

### Fixes

- Pin cAdvisor to a released version instead of a moving tag
- Remove a stray Grafana provider config from the dashboards directory

### Dependencies

- Bump Prometheus from v3.13.2 to v3.14.0
- Bump Loki from 3.7.6 to 3.7.7
- Bump Alloy from v1.18.1 to v1.19.2
- Bump Uptime Kuma from 2.5.0 to 2.5.4

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.3.1] - 2026-08-14

Updates pinned monitoring stack images and GitHub Actions to their latest versions.

### Dependencies

- Bump Prometheus from v3.11.3 to v3.13.2
- Bump Grafana OSS from 13.0.1 to 13.0.2
- Bump Loki from 3.7.2 to 3.7.6
- Bump Alloy from v1.16.1 to v1.18.1
- Bump Uptime Kuma from 2.3.2 to 2.5.0
- Bump actions/checkout and actions/setup-python from 6 to 7

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.3.0] - 2026-05-22

Adds provisioned dashboards and refreshed Loki image support for monitoring stack deployments.

### Features

- Bundled exported dashboards for cAdvisor, FritzBox cable monitoring, Traefik, host monitoring, and logs.
- Added cAdvisor scraping so container metrics feed the bundled dashboard.

### Dependencies

- Updated Loki from 3.7.1 to 3.7.2.

### Documentation & Links

- Clarified that the FritzBox dashboard is bundled.
- Source: GitHub release archive.

## [v1.2.3] - 2026-05-10

Fixes the cAdvisor image reference so the monitoring stack can be recreated from the committed Compose file.

### Fixes

- Switched cAdvisor to the available GHCR `latest` tag.
- Ignored local Compose override files.

### Documentation & Links

- Source: GitHub release archive.

## [v1.2.2] - 2026-05-10

Updates pinned monitoring stack images and enables Dependabot coverage for Docker Compose image references.

### Dependencies

- Updated Prometheus, Grafana OSS, Loki, and Grafana Alloy image tags.
- Switched Dependabot image tracking to Docker Compose files.

### Documentation & Links

- Source: GitHub release archive.

## [v1.2.1] - 2026-05-09

Restores client names in the OpenWrt WiFi dashboard while preserving real signal values.

### Fixes

- Restored FritzBox host name and IP display for WiFi station signal panels.
- Kept signal values unchanged when FritzBox reports a named host as inactive.

### Documentation & Links

- Source: GitHub release archive.

## [v1.2.0] - 2026-05-09

Monitoring Stack now reduces Grafana telemetry traffic and makes OpenWrt WiFi dashboards easier to read.

### Features

- Aggregate OpenWrt WiFi panels by band instead of repeated per-interface rows
- Deduplicate WiFi clients by MAC address for clearer connected-device counts

### Fixes

- Disable Grafana Alloy reporting calls
- Disable Loki analytics reporting

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.1.2] - 2026-05-09

Monitoring Stack now uses healthcheck behavior that matches the shipped container images.

### Fixes

- Disable the Loki container healthcheck where the image does not provide a suitable local probe
- Start Alloy after Loki is running and probe Alloy through its local TCP port
- Use `curl` for the Uptime Kuma healthcheck

### Documentation & Links

- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.1.1] - 2026-05-09

Monitoring Stack now documents data retention behavior and volume backup/restore commands for self-hosted maintenance.

### Documentation & Links

- Document Prometheus and Loki retention defaults
- Add backup and restore commands for named Docker volumes
- Ignore local backup archives and editor backup files
- [README](https://github.com/fabianwimberger/monitoring-stack#readme)

## [v1.1.0] - 2026-05-09

Grafana datasource provisioning, healthchecks, and security fixes.

### Fixes
- Prometheus and Loki datasource provisioning so dashboards work on first boot
- Dashboard provider yaml moved to correct path (separate from JSON files)
- Healthchecks on all services with service_healthy conditions
- Log rotation (max-size/max-file) on all containers
- Alloy runs as grafana user instead of root
- Invalid cAdvisor flags removed (removed in upstream v0.47+)
- Loki instance_addr changed to routable address
- Empty alertmanagers block removed from Prometheus config
- DOCKER_GID support added, Makefile help target, README updates

### Documentation & Links
- https://github.com/fabianwimberger/monitoring-stack

## [v1.0.0] - 2026-05-02

**The first official release of a Docker Compose monitoring stack for self-hosted infrastructure. Metrics, logs, dashboards, and uptime monitoring in one command.**

### Features

- **Metrics** — Prometheus + cAdvisor + node_exporter
- **Logs** — Loki + Grafana Alloy (Docker containers + systemd journal)
- **Dashboards** — Grafana with pre-provisioned dashboards
- **Uptime** — Uptime Kuma for endpoint monitoring
- **Network isolation** — Two Docker networks for security (internal + proxy)
- **Proxy overlay** — Optional Traefik-ready compose for reverse-proxy deployments

### Companion Integration

This stack is designed to work with two other projects as data sources:

| Repo | Integration |
|---|---|
| [openwrt-only-home-network](https://github.com/fabianwimberger/openwrt-only-home-network) | OpenWrt WiFi dashboard via node_exporter |
| [fritzbox-monitoring](https://github.com/fabianwimberger/fritzbox-monitoring) | FritzBox cable modem metrics dashboard |

### Quick Start

```bash
git clone https://github.com/fabianwimberger/monitoring-stack.git
cd monitoring-stack
cp .env.example .env
make up
```

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Uptime Kuma | http://localhost:3001 |

For reverse proxy mode, use `make up-proxy` after setting `GRAFANA_DOMAIN` and `UPTIME_KUMA_DOMAIN` in `.env`.

### Requirements

- Docker and Docker Compose v2
- Linux host (for systemd journal and cAdvisor access)
- [node_exporter](https://github.com/prometheus/node_exporter) installed on hosts you want to monitor

### License

[MIT](LICENSE)
