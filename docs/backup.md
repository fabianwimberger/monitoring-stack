# Backup and Restore

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
