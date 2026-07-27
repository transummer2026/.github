#!/usr/bin/env bash
# Normalise une PR : assigne son auteur si aucun assignee n'est defini,
# puis force le titre au format Conventional Commits en le derivant du
# nom de branche (type/sujet) quand il n'est pas deja conforme.
set -euo pipefail

TYPES='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'

# Assigne l'auteur de la PR. No-op si un assignee existe deja ou si
# l'auteur est un bot (non assignable) : ne doit jamais faire echouer la CI.
assign_author() {
  local count author is_bot

  count=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json assignees --jq '.assignees | length')
  if [[ "$count" -gt 0 ]]; then
    echo "PR already assigned, skipping"
    return 0
  fi

  author=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json author --jq '.author.login')
  is_bot=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json author --jq '.author.is_bot')
  if [[ -z "$author" || "$author" == "null" || "$is_bot" == "true" ]]; then
    echo "::warning::PR author '$author' is not assignable, skipping"
    return 0
  fi

  if gh pr edit "$PR_NUMBER" --repo "$REPO" --add-assignee "$author"; then
    echo "Assigned PR to $author"
  else
    echo "::warning::Failed to assign PR to $author"
  fi
}

# Verifie le titre de PR et le reecrit depuis le nom de branche si besoin.
# Sort en erreur quand la branche ne permet pas de deriver un titre valide.
normalize_title() {
  local title raw_type raw_subject type subject new_title

  title=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json title --jq .title)

  if [[ "$title" =~ ^($TYPES)(\([a-zA-Z0-9._/-]+\))?\!?:\ .+ ]]; then
    echo "Title already valid: $title"
    return 0
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
    echo "Title normalized: '$title' -> '$new_title'"
    return 0
  fi
  shopt -u nocasematch

  echo "::error::Invalid PR title ('$title') and branch '$HEAD_REF' is not derivable (expected: type/subject). Fix the title as 'type: subject' in the GitHub UI."
  return 1
}

assign_author
normalize_title
