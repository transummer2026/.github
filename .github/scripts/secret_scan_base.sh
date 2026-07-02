#!/usr/bin/env bash
set -euo pipefail

ZERO="0000000000000000000000000000000000000000"
base=""

if [ -n "${EVENT_BEFORE:-}" ] && [ "$EVENT_BEFORE" != "$ZERO" ] \
   && git cat-file -e "${EVENT_BEFORE}^{commit}" 2>/dev/null; then
  base="$EVENT_BEFORE"
elif [ -n "${DEFAULT_BRANCH:-}" ]; then
  git fetch origin "$DEFAULT_BRANCH" --quiet 2>/dev/null || true
  base=$(git merge-base "origin/${DEFAULT_BRANCH}" HEAD 2>/dev/null || true)
fi

if [ -n "$base" ] && [ "$base" = "$(git rev-parse HEAD)" ]; then
  base=""
fi

echo "base=$base" >> "$GITHUB_OUTPUT"
echo "Base secret scan : ${base:-<scan complet>}"
