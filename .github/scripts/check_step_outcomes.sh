#!/usr/bin/env bash
set -euo pipefail

# BLOCKING=false : bilan purement informatif — les échecs sortent en
# ::warning et le script ne fait pas échouer le job.
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"
BLOCKING="${BLOCKING:-true}"
failed=()
total=0

{
  echo "### Bilan des checks — job \`${GITHUB_JOB:-?}\`"
  echo ""
  echo "| Check | Statut |"
  echo "| :---- | :----- |"
} >> "$SUMMARY"

while IFS='=' read -r name outcome; do
  [ -z "$name" ] && continue
  total=$((total + 1))
  case "$outcome" in
    failure)
      failed+=("$name")
      if [ "$BLOCKING" = "true" ]; then
        echo "::error title=Check en échec::${name} a échoué — voir le step '${name}' dans ce job"
        echo "| \`$name\` | ❌ échec |" >> "$SUMMARY"
      else
        echo "::warning title=Check en échec (non bloquant)::${name} a échoué — voir le step '${name}' dans ce job"
        echo "| \`$name\` | ⚠️ échec (non bloquant) |" >> "$SUMMARY"
      fi
      ;;
    success)
      echo "$name : success"
      echo "| \`$name\` | ✅ succès |" >> "$SUMMARY"
      ;;
    skipped)
      echo "$name : skipped"
      echo "| \`$name\` | ⏭️ non applicable |" >> "$SUMMARY"
      ;;
    *)
      echo "$name : $outcome"
      echo "| \`$name\` | ❓ $outcome |" >> "$SUMMARY"
      ;;
  esac
done <<< "$OUTCOMES"

echo "" >> "$SUMMARY"

if [ "${#failed[@]}" -gt 0 ]; then
  if [ "$BLOCKING" = "true" ]; then
    {
      echo "**❌ ${#failed[@]}/${total} check(s) en échec : ${failed[*]}**"
      echo ""
      echo "> Chaque check tourne jusqu'au bout (continue-on-error) : corrige tout ce qui est ❌ en un seul passage."
    } >> "$SUMMARY"
    echo ""
    echo "❌ ${#failed[@]}/${total} check(s) en échec : ${failed[*]}"
    exit 1
  fi
  {
    echo "**⚠️ ${#failed[@]}/${total} check(s) en échec : ${failed[*]} — informatif, ne bloque pas la CI**"
  } >> "$SUMMARY"
  echo ""
  echo "⚠️ ${#failed[@]}/${total} check(s) en échec : ${failed[*]} (non bloquant)"
  exit 0
fi

echo "**✅ ${total}/${total} checks passés**" >> "$SUMMARY"
echo "✅ Tous les checks sont passés (${total}/${total})"
