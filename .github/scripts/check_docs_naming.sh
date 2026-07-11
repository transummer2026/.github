#!/usr/bin/env bash
set -uo pipefail

export LC_ALL=en_US.UTF-8

mapfile -t IGNORED_FOLDERS   < <(jq -r '.ignored_folders[]'        .ci_config.json 2>/dev/null)
mapfile -t IGNORED_FILES     < <(jq -r '.ignored_files[]'          .ci_config.json 2>/dev/null)
mapfile -t IGNORED_TEMPLATES < <(jq -r '.ignored_Templates_files[]' .ci_config.json 2>/dev/null)

folder_errors=()
file_errors=()
template_errors=()

is_ignored_path() {
  local path="$1"; shift
  for pattern in "$@"; do
    [[ "$path" == *"/$pattern"* || "$path" == *"/$pattern" ]] && return 0
  done
  return 1
}

is_ignored_file() {
  local entry="$1" base="$2"; shift 2
  for pattern in "$@"; do
    if [[ "$pattern" == */* || "$pattern" == *\** ]]; then
      [[ "$entry" == ./$pattern ]] && return 0
    else
      [[ "$base" == "$pattern" ]] && return 0
    fi
  done
  return 1
}

check_train_case() {
  [[ "$1" =~ ^[[:upper:]][[:alnum:]]*([-][[:alnum:]]+)*$ ]]
}

while read -r entry; do
  if [ -d "$entry" ]; then
    is_ignored_path "$entry" "${IGNORED_FOLDERS[@]}" && continue
    name=$(basename "$entry")
    if ! [[ "$name" =~ ^[[:upper:]][[:lower:][:digit:]]*(_[[:lower:][:digit:]]+)*$ ]]; then
      folder_errors+=("  $entry")
    fi

  else
    base=$(basename "$entry")

    is_ignored_path "$entry" "${IGNORED_FOLDERS[@]}" && continue

    if [[ "$entry" == ./Template/* ]]; then
      is_ignored_file "$entry" "$base" "${IGNORED_TEMPLATES[@]}" && continue
      check="${base#_}"
      if ! [[ "$check" =~ ^Template[-_] ]]; then
        template_errors+=("  $entry")
      fi
      continue
    fi

    is_ignored_file "$entry" "$base" "${IGNORED_FILES[@]}" && continue
    if [[ "$base" == *.md ]]; then
      name="${base#_}"; name="${name%.md}"
    else
      name="${base%.*}"
    fi
    if ! check_train_case "$name"; then
      file_errors+=("  $entry")
    fi
  fi
done < <(find . -mindepth 1 -maxdepth 3 ! -path './.git*' ! -path './.ci*' \( -type f -o -type d \))

total=$(( ${#folder_errors[@]} + ${#file_errors[@]} + ${#template_errors[@]} ))

if [ ${#folder_errors[@]} -gt 0 ]; then
  echo "❌ Dossiers mal nommés (${#folder_errors[@]}) — attendu Snake_case"
  printf '%s\n' "${folder_errors[@]}"
  echo ""
fi
if [ ${#template_errors[@]} -gt 0 ]; then
  echo "❌ Template sans préfixe TPL (${#template_errors[@]})"
  printf '%s\n' "${template_errors[@]}"
  echo ""
fi
if [ ${#file_errors[@]} -gt 0 ]; then
  echo "❌ Fichiers mal nommés (${#file_errors[@]}) — attendu Train-Case"
  printf '%s\n' "${file_errors[@]}"
  echo ""
fi

if [ "$total" -gt 0 ]; then
  echo "Total : $total erreur(s)"
  exit 1
else
  echo "✅ Tous les nommages sont corrects"
fi
