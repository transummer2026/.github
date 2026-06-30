#!/usr/bin/env bash
set -euo pipefail

COVERAGE=0
case "${COVERAGE_FORMAT:-lcov}" in
  cobertura)
    COVERAGE=$(grep -oP 'line-rate="\K[0-9.]+' coverage.xml | head -1 | awk '{printf "%d", $1 * 100}')
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
