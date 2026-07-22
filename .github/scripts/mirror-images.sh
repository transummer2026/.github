#!/usr/bin/env bash
set -euo pipefail

ELK_VERSION="${ELK_VERSION:-9.0.0}"

# NOTE modsecurity: les builds 2026-07 upstream ne publient que linux/386,
# on épingle le dernier build multi-arch connu (amd64+arm64).
images=(
  "docker.io/prom/prometheus:latest=>ghcr.io/transummer2026/prometheus:latest"
  "docker.io/prom/alertmanager:latest=>ghcr.io/transummer2026/alertmanager:latest"
  "docker.io/prom/node-exporter:latest=>ghcr.io/transummer2026/node-exporter:latest"
  "docker.io/prometheuscommunity/postgres-exporter:latest=>ghcr.io/transummer2026/postgres-exporter:latest"
  "docker.io/oliver006/redis_exporter:latest=>ghcr.io/transummer2026/redis-exporter:latest"
  "docker.io/nginx/nginx-prometheus-exporter:latest=>ghcr.io/transummer2026/nginx-exporter:latest"
  "docker.io/prom/blackbox-exporter:latest=>ghcr.io/transummer2026/blackbox-exporter:latest"
  "gcr.io/cadvisor/cadvisor:latest=>ghcr.io/transummer2026/cadvisor:latest"
  "docker.io/grafana/grafana:latest=>ghcr.io/transummer2026/grafana:latest"
  "docker.io/nginx:alpine=>ghcr.io/transummer2026/nginx:alpine"
  "docker.io/certbot/certbot:latest=>ghcr.io/transummer2026/certbot:latest"
  "docker.io/owasp/modsecurity-crs:4.27.0-nginx-alpine-202606290906=>ghcr.io/transummer2026/modsecurity:latest"
  "docker.io/hashicorp/vault:latest=>ghcr.io/transummer2026/vault:latest"
  "docker.io/postgres:16-alpine=>ghcr.io/transummer2026/postgres:16-alpine"
  "docker.io/redis:7-alpine=>ghcr.io/transummer2026/redis:7-alpine"
  "docker.io/dxflrs/garage:v2.3.0=>ghcr.io/transummer2026/garage:v2.3.0"
  "docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}=>ghcr.io/transummer2026/elasticsearch:${ELK_VERSION}"
  "docker.elastic.co/logstash/logstash:${ELK_VERSION}=>ghcr.io/transummer2026/logstash:${ELK_VERSION}"
  "docker.elastic.co/kibana/kibana:${ELK_VERSION}=>ghcr.io/transummer2026/kibana:${ELK_VERSION}"
)

ok=()
ko=()
skipped=()

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

  src_digest="$(awk '/^Digest:/{print $2; exit}' <<<"${inspect}")"
  dst_digest="$(docker buildx imagetools inspect "${dst}" 2>/dev/null | awk '/^Digest:/{print $2; exit}' || true)"
  if [[ -n "${src_digest}" && "${src_digest}" == "${dst_digest}" ]]; then
    echo "Déjà à jour sur GHCR (digest ${src_digest}), rien à mirrorer."
    echo "::endgroup::"
    skipped+=("${dst}")
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
    for img in ${ok[@]+"${ok[@]}"}; do echo "| \`${img}\` | ✅ mirée (nouvelle version) |"; done
    for img in ${skipped[@]+"${skipped[@]}"}; do echo "| \`${img}\` | ⏭️ déjà à jour |"; done
    for img in ${ko[@]+"${ko[@]}"}; do echo "| \`${img}\` | ❌ échec |"; done
  } >>"${GITHUB_STEP_SUMMARY}"
fi

if ((${#ko[@]} > 0)); then
  echo "::error title=Mirror incomplet::${#ko[@]} image(s) en échec : ${ko[*]}"
  exit 1
fi

echo "✓ ${#ok[@]} image(s) mirée(s), ${#skipped[@]} déjà à jour"
