#!/usr/bin/env bash
set -euo pipefail

# Statut global d'un run CI à partir des résultats de jobs.
# "skipped" sur checks/quality est un skip volontaire (push dev : la
# validation a déjà tourné sur la PR), pas un échec. CHECKS_RESULT et
# QUALITY_RESULT sont optionnels (ci-services-push ne passe que QUALITY).

ok() { [ "$1" = "success" ] || [ "$1" = "skipped" ]; }

emit() {
  echo "result=$1" >> "$GITHUB_OUTPUT"
  echo "status_code=$2" >> "$GITHUB_OUTPUT"
}

if ! ok "${CHECKS_RESULT:-success}" || ! ok "${QUALITY_RESULT:-success}"; then
  emit failure 2
elif [ "${BUILD_RESULT}" = "success" ]; then
  emit success 1
elif [ "${BUILD_RESULT}" = "skipped" ] && [ "${SKIP_BUILD:-false}" = "true" ]; then
  emit success 1
else
  emit failure 2
fi
