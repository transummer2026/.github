#!/usr/bin/env bash
set -euo pipefail

ELK_VERSION="${ELK_VERSION:-9.0.0}"

images=(
  "docker.io/prom/prometheus:latest=>ghcr.io/transummer2026/prometheus:latest"
  "docker.io/grafana/grafana:latest=>ghcr.io/transummer2026/grafana:latest"
  "docker.io/nginx:alpine=>ghcr.io/transummer2026/nginx:alpine"
  "docker.io/owasp/modsecurity-crs:nginx-alpine=>ghcr.io/transummer2026/modsecurity:latest"
  "docker.io/hashicorp/vault:latest=>ghcr.io/transummer2026/vault:latest"
  "docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}=>ghcr.io/transummer2026/elasticsearch:${ELK_VERSION}"
  "docker.elastic.co/logstash/logstash:${ELK_VERSION}=>ghcr.io/transummer2026/logstash:${ELK_VERSION}"
  "docker.elastic.co/kibana/kibana:${ELK_VERSION}=>ghcr.io/transummer2026/kibana:${ELK_VERSION}"
)

fail=0

for pair in "${images[@]}"; do
  src="${pair%%=>*}"
  dst="${pair##*=>}"

  echo "::group::Mirror ${src} -> ${dst}"

  inspect="$(docker buildx imagetools inspect "${src}" 2>&1 || true)"
  if ! grep -q "linux/arm64" <<<"${inspect}" || ! grep -q "linux/amd64" <<<"${inspect}"; then
    echo "::error::Source ${src} introuvable ou pas multi-arch (amd64+arm64 attendus)."
    echo "${inspect}"
    echo "::endgroup::"
    fail=1
    continue
  fi

  docker buildx imagetools create --tag "${dst}" "${src}"

  echo "Plateformes & digest de l'index (à épingler dans compose) :"
  docker buildx imagetools inspect "${dst}"
  echo "::endgroup::"
done

exit "${fail}"
