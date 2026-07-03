#!/usr/bin/env bash
set -euo pipefail

failed=()
while IFS='=' read -r name outcome; do
  [ -z "$name" ] && continue
  if [ "$outcome" = "failure" ]; then
    failed+=("$name")
    echo "::error::Check en échec : $name"
  else
    echo "$name : $outcome"
  fi
done <<< "$OUTCOMES"

if [ "${#failed[@]}" -gt 0 ]; then
  echo ""
  echo "❌ ${#failed[@]} check(s) en échec : ${failed[*]}"
  exit 1
fi
echo "✅ Tous les checks sont passés"
