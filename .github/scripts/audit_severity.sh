#!/usr/bin/env bash
set -euo pipefail

SEVERITY="none"
if [ -n "${AUDIT_CMD:-}" ]; then
  set +e
  OUTPUT=$(eval "$AUDIT_CMD" 2>&1)
  set -e
  echo "$OUTPUT"
  if echo "$OUTPUT" | grep -qiE "critical"; then
    SEVERITY="critical"
  elif echo "$OUTPUT" | grep -qiE "high"; then
    SEVERITY="high"
  elif echo "$OUTPUT" | grep -qiE "moderate|medium|low"; then
    SEVERITY="low"
  fi
fi
echo "severity=${SEVERITY}" >> "$GITHUB_OUTPUT"
