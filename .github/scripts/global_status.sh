#!/usr/bin/env bash
set -euo pipefail

if [ "${BUILD_RESULT}" = "success" ]; then
  echo "result=success" >> "$GITHUB_OUTPUT"
  echo "status_code=1" >> "$GITHUB_OUTPUT"
else
  echo "result=failure" >> "$GITHUB_OUTPUT"
  echo "status_code=2" >> "$GITHUB_OUTPUT"
fi
