#!/usr/bin/env bash
set -euo pipefail

case "$SERVICE_NAME" in
  frontend|backend|api) lang="node" ;;
  ai)               lang="python" ;;
  gateway)          lang="rust" ;;
  *)
    echo "::error::Service inconnu pour la détection de langage : $SERVICE_NAME"
    exit 1
    ;;
esac

echo "language=$lang" >> "$GITHUB_OUTPUT"
echo "Service '$SERVICE_NAME' → langage '$lang'"
