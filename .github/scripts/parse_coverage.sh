#!/usr/bin/env bash
# Extrait le pourcentage de coverage du rapport et l'écrit dans $GITHUB_OUTPUT
# (coverage=N). Pour cobertura, le nom du rapport dépend de l'outil : pytest
# écrit coverage.xml, tarpaulin cobertura.xml, jest coverage/cobertura-coverage.xml
# -> on prend le premier trouvé. Best-effort : rapport absent ou format inconnu,
# retombe à 0 sans échouer.
set -euo pipefail

COVERAGE=0
case "${COVERAGE_FORMAT:-lcov}" in
  cobertura)
    for f in coverage.xml cobertura.xml coverage/cobertura-coverage.xml; do
      if [ -f "$f" ] && [ -s "$f" ]; then
        COVERAGE=$(grep -oP 'line-rate="\K[0-9.]+' "$f" | head -1 | awk '{printf "%d", $1 * 100}')
        break
      fi
    done
    ;;
  lcov)
    if [ -f "coverage/lcov.info" ] && [ -s "coverage/lcov.info" ]; then
      TOTAL=$(grep -E "^LF:" coverage/lcov.info | awk -F: '{sum+=$2} END{print sum}')
      HIT=$(grep -E "^LH:" coverage/lcov.info | awk -F: '{sum+=$2} END{print sum}')
      if [ "${TOTAL:-0}" -gt 0 ]; then
        COVERAGE=$(awk "BEGIN {printf \"%d\", ($HIT/$TOTAL)*100}")
      fi
    fi
    ;;
esac

echo "coverage=${COVERAGE}" >> "$GITHUB_OUTPUT"
echo "Coverage: ${COVERAGE}%"
