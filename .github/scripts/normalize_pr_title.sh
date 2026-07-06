#!/usr/bin/env bash
set -euo pipefail

TYPES='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'

title=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json title --jq .title)

if [[ "$title" =~ ^($TYPES)(\([a-zA-Z0-9._/-]+\))?\!?:\ .+ ]]; then
  echo "Titre déjà conforme : $title"
  exit 0
fi

shopt -s nocasematch
if [[ "$HEAD_REF" =~ ^($TYPES)/(.+)$ ]]; then
  raw_type="${BASH_REMATCH[1]}"
  raw_subject="${BASH_REMATCH[2]}"
  shopt -u nocasematch
  type=$(printf '%s' "$raw_type" | tr '[:upper:]' '[:lower:]')
  subject=$(printf '%s' "$raw_subject" | tr '_/-' '   ' | tr '[:upper:]' '[:lower:]' | tr -s ' ')
  new_title="${type}: ${subject}"
  gh pr edit "$PR_NUMBER" --repo "$REPO" --title "$new_title"
  echo "Titre normalisé : '$title' → '$new_title'"
  exit 0
fi

echo "::error::Titre PR non conforme ('$title') et branche '$HEAD_REF' non dérivable (attendu : type/sujet). Corrige le titre au format 'type: sujet' dans l'UI GitHub."
exit 1
