# Observability Notes

## Stack Added

- Prometheus (`http://localhost:9090`)
- Grafana (`http://localhost:3001`)

Configured in:

- `docker-compose.yml`
- `observability/prometheus/prometheus.yml`

## What Is Measured

Prometheus scrapes its own target (`prometheus:9090`) by default, which provides:

- Target health (`up`)
- Scrape metrics (`scrape_duration_seconds`, `scrape_samples_*`)
- TSDB metrics (`prometheus_tsdb_*`)

## Suggested Demo Steps

1. Start services:

```bash
docker compose up -d
```

2. Open Prometheus and verify target:
   - URL: `http://localhost:9090/targets`
   - Ensure job `prometheus` is `UP`

3. Open Grafana:
   - URL: `http://localhost:3001`
   - Username/password: `admin` / `admin`
   - Add Prometheus datasource: `http://prometheus:9090`
   - Build dashboard panels for:
     - `up`
     - `rate(prometheus_http_requests_total[5m])`
     - `prometheus_tsdb_head_series`

## Suggested Screenshots for Submission

- Docker containers running (`docker compose ps`)
- Prometheus targets page showing `UP`
- Grafana dashboard panel with time-series metrics
