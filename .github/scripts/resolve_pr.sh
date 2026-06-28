#!/usr/bin/env bash
#
# resolve_pr.sh — Résout la PR d'origine d'un commit poussé (best-effort).
#
# Interroge l'API GitHub pour la/les PR associée(s) au commit, et expose
# ses métadonnées aux steps suivants. Sans PR (push direct), les sorties
# sont vides plutôt qu'en erreur — l'appelant reste simple à écrire.
#
# Entrées (env) :
#   REPO      owner/name du dépôt (ex: transummer2026/Pollpear_backend)
#   SHA       SHA du commit à résoudre
#   GH_TOKEN  token avec accès lecture aux PR du dépôt
#
# Sorties (GITHUB_OUTPUT) :
#   number    numéro de la PR (ex: 42) ou ""
#   title     titre de la PR ou ""
#   url       URL html de la PR ou ""
#
set -euo pipefail

: "${REPO:?REPO requis}"
: "${SHA:?SHA requis}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT requis}"

pr_json="$(
  gh api "repos/${REPO}/commits/${SHA}/pulls" \
    -H "Accept: application/vnd.github+json" \
    --jq '.[0] // {}' 2>/dev/null || echo '{}'
)"

emit() {
  printf '%s=%s\n' "$1" "$(jq -r "$2 // \"\"" <<<"$pr_json")" >>"$GITHUB_OUTPUT"
}

emit number .number
emit title  .title
emit url    .html_url
