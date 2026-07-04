#!/usr/bin/env bash
set -euo pipefail

ELK_VERSION="${ELK_VERSION:-9.0.0}"

# NOTE modsecurity: les builds 2026-07 upstream ne publient que linux/386,
# on épingle le dernier build multi-arch connu (amd64+arm64).
images=(
  "docker.io/prom/prometheus:latest=>ghcr.io/transummer2026/prometheus:latest"
  "docker.io/prom/node-exporter:latest=>ghcr.io/transummer2026/node-exporter:latest"
  "docker.io/prometheuscommunity/postgres-exporter:latest=>ghcr.io/transummer2026/postgres-exporter:latest"
  "docker.io/oliver006/redis_exporter:latest=>ghcr.io/transummer2026/redis-exporter:latest"
  "docker.io/grafana/grafana:latest=>ghcr.io/transummer2026/grafana:latest"
  "docker.io/nginx:alpine=>ghcr.io/transummer2026/nginx:alpine"
  "docker.io/owasp/modsecurity-crs:4.27.0-nginx-alpine-202606290906=>ghcr.io/transummer2026/modsecurity:latest"
  "docker.io/hashicorp/vault:latest=>ghcr.io/transummer2026/vault:latest"
  "docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}=>ghcr.io/transummer2026/elasticsearch:${ELK_VERSION}"
  "docker.elastic.co/logstash/logstash:${ELK_VERSION}=>ghcr.io/transummer2026/logstash:${ELK_VERSION}"
  "docker.elastic.co/kibana/kibana:${ELK_VERSION}=>ghcr.io/transummer2026/kibana:${ELK_VERSION}"
)

ok=()
ko=()

for pair in "${images[@]}"; do
  src="${pair%%=>*}"
  dst="${pair##*=>}"

  echo "::group::Mirror ${src} -> ${dst}"

  inspect="$(docker buildx imagetools inspect "${src}" 2>&1 || true)"
  if ! grep -q "linux/arm64" <<<"${inspect}" || ! grep -q "linux/amd64" <<<"${inspect}"; then
    echo "::error title=Image non mirée::${src} introuvable ou pas multi-arch (amd64+arm64 attendus)."
    echo "${inspect}"
    echo "::endgroup::"
    ko+=("${src}")
    continue
  fi

  if ! docker buildx imagetools create --tag "${dst}" "${src}"; then
    echo "::error title=Push GHCR échoué::${src} -> ${dst}"
    echo "::endgroup::"
    ko+=("${src}")
    continue
  fi

  echo "Plateformes & digest de l'index (à épingler dans compose) :"
  docker buildx imagetools inspect "${dst}"
  echo "::endgroup::"
  ok+=("${dst}")
done

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## Mirror Docker Hub → GHCR"
    echo ""
    echo "| Image | Statut |"
    echo "|---|---|"
    for img in ${ok[@]+"${ok[@]}"}; do echo "| \`${img}\` | ✅ mirée |"; done
    for img in ${ko[@]+"${ko[@]}"}; do echo "| \`${img}\` | ❌ échec |"; done
  } >>"${GITHUB_STEP_SUMMARY}"
fi

if ((${#ko[@]} > 0)); then
  echo "::error title=Mirror incomplet::${#ko[@]} image(s) en échec : ${ko[*]}"
  exit 1
fi

echo "✓ ${#ok[@]} images mirées avec succès"
