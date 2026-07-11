#!/usr/bin/env bash
set -euo pipefail

case "$SERVICE_NAME" in
  frontend|backend|api|shared) lang="node" ;;
  ai)               lang="python" ;;
  gateway)          lang="rust" ;;
  *)
    echo "::error::Service inconnu pour la détection de langage : $SERVICE_NAME"
    lang="";;
esac

# Repo squelette (pas encore de fichier projet) : has_project=false permet
# aux workflows de skipper install/lint/tests/coverage au lieu d'échouer.
has_project="false"
case "$lang" in
  node)   if [ -f package.json ]; then has_project="true"; fi ;;
  python) if [ -f pyproject.toml ] || [ -f requirements.txt ]; then has_project="true"; fi ;;
  rust)   if [ -f Cargo.toml ]; then has_project="true"; fi ;;
esac

echo "language=$lang" >> "$GITHUB_OUTPUT"
echo "has_project=$has_project" >> "$GITHUB_OUTPUT"
echo "Service '$SERVICE_NAME' → langage '$lang' (fichier projet : $has_project)"
