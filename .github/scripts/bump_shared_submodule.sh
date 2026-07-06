#!/usr/bin/env bash
set -euo pipefail

SUBMODULE_PATH="Pollpear_shared"
SHORT_SHA="${SHARED_SHA:0:7}"
BRANCH="chore/bump-shared-${SHORT_SHA}"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git -C "$SUBMODULE_PATH" fetch origin "$SHARED_SHA"
git -C "$SUBMODULE_PATH" checkout --quiet "$SHARED_SHA"

if git diff --quiet -- "$SUBMODULE_PATH"; then
  echo "Submodule déjà sur ${SHORT_SHA} — rien à faire."
  exit 0
fi

git checkout -b "$BRANCH"
git add "$SUBMODULE_PATH"
git commit -m "chore: bump shared to ${SHORT_SHA}"
git push --force -u origin "$BRANCH"

pr_url=$(gh pr create --base dev --head "$BRANCH" \
  --title "chore: bump shared to ${SHORT_SHA}" \
  --body "Bump automatique du submodule \`${SUBMODULE_PATH}\` vers \`${SHARED_REPO:-shared}@${SHORT_SHA}\` (déclenché par @${ACTOR:-ci}).") \
  || pr_url=$(gh pr view "$BRANCH" --json url --jq .url)
echo "PR : $pr_url"

gh pr merge --auto --squash "$pr_url" \
  || echo "::warning::Auto-merge indisponible (à activer dans les settings du repo) — merge manuel requis : $pr_url"
