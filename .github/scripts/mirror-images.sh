
set -euo pipefail


images=(
  "docker.io/prom/prometheus:latest=>ghcr.io/transummer2026/prometheus:latest"
  "docker.io/grafana/grafana:latest=>ghcr.io/transummer2026/grafana:latest"
  "docker.io/nginx:alpine=>ghcr.io/transummer2026/nginx:alpine"
  "docker.io/owasp/modsecurity-crs:nginx-alpine=>ghcr.io/transummer2026/modsecurity:latest"
  "docker.io/hashicorp/vault:latest=>ghcr.io/transummer2026/vault:latest"
  "docker.elastic.co/elasticsearch/elasticsearch:latest=>ghcr.io/transummer2026/elasticsearch:latest"
  "docker.elastic.co/logstash/logstash:latest=>ghcr.io/transummer2026/logstash:latest"
  "docker.elastic.co/kibana/kibana:latest=>ghcr.io/transummer2026/kibana:latest"
)

for pair in "${images[@]}"; do
  src="${pair%%=>*}"
  dst="${pair##*=>}"

  echo "::group::Mirror ${src} -> ${dst}"
  docker buildx imagetools create --tag "${dst}" "${src}"

  echo "Plateformes & digest de l'index (à épingler dans compose) :"
  docker buildx imagetools inspect "${dst}"
  echo "::endgroup::"
done
