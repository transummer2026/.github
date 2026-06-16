#!/usr/bin/env bash
# Extrait le nombre de tests réussis depuis la sortie capturée (test-output.log)
# et l'écrit dans $GITHUB_OUTPUT (test_count=N). Détection par contenu : cargo / jest / pytest.
# Télémétrie best-effort : si le format n'est pas reconnu, retombe à 0 sans échouer.
set -euo pipefail

LOG="${TEST_LOG:-test-output.log}"
COUNT=0

if [ -f "$LOG" ]; then
  if grep -qE '^test result:' "$LOG"; then
    # cargo test : une ligne "test result: ok. N passed; ..." par binaire -> somme
    COUNT=$(grep -oE '[0-9]+ passed' "$LOG" | awk '{sum+=$1} END{print sum+0}')
  elif grep -qE '^[[:space:]]*Tests:' "$LOG"; then
    # jest : "Tests: N passed, M total" (on cible la ligne Tests:, pas "Test Suites:")
    COUNT=$(grep -E '^[[:space:]]*Tests:' "$LOG" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' | head -1)
  elif grep -qE '[0-9]+ passed' "$LOG"; then
    # pytest : "===== N passed in 0.5s ====="
    COUNT=$(grep -oE '[0-9]+ passed' "$LOG" | tail -1 | grep -oE '[0-9]+')
  fi
fi

echo "test_count=${COUNT:-0}" >> "$GITHUB_OUTPUT"
echo "Tests passed: ${COUNT:-0}"
