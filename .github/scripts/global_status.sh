#!/usr/bin/env bash
set -euo pipefail

if [ "${BUILD_RESULT}" = "success" ]; then
  echo "result=success" >> "$GITHUB_OUTPUT"
  echo "status_code=1" >> "$GITHUB_OUTPUT"
elif [ "${BUILD_RESULT}" = "skipped" ] && [ "${SKIP_BUILD:-false}" = "true" ]; then
  if [ "${QUALITY_RESULT:-}" = "success" ]; then
    echo "result=success" >> "$GITHUB_OUTPUT"
    echo "status_code=1" >> "$GITHUB_OUTPUT"
  else
    echo "result=failure" >> "$GITHUB_OUTPUT"
    echo "status_code=2" >> "$GITHUB_OUTPUT"
  fi
else
  echo "result=failure" >> "$GITHUB_OUTPUT"
  echo "status_code=2" >> "$GITHUB_OUTPUT"
fi
