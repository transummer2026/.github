#!/usr/bin/env bash
set -euo pipefail

if [ "${COVERAGE}" -lt "${THRESHOLD}" ]; then
  echo "Coverage ${COVERAGE}% < seuil ${THRESHOLD}%"
  exit 1
fi
echo "Coverage ${COVERAGE}% >= seuil ${THRESHOLD}%"
