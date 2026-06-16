#!/usr/bin/env bash
set -euo pipefail

SEVERITY="none"
if [ -n "${AUDIT_CMD:-}" ]; then
  set +e
  OUTPUT=$(eval "$AUDIT_CMD" 2>&1)
  set -e
  echo "$OUTPUT"
  if echo "$OUTPUT" | grep -qiE "critical|high"; then
    SEVERITY="critical"
  elif echo "$OUTPUT" | grep -qiE "medium|low"; then
    SEVERITY="low"
  fi
fi
echo "severity=${SEVERITY}" >> "$GITHUB_OUTPUT"
