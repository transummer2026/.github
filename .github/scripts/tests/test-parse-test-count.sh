#!/usr/bin/env bash
# Tests de régression pour parse-test-count.sh : vérifie la détection cargo / jest / pytest / aucun.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSER="${HERE}/../parse-test-count.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0

# Lance le parser sur un log donné et renvoie la valeur de test_count écrite dans $GITHUB_OUTPUT.
run_case() {
  local name="$1" expected="$2" log="$3"
  local out="${TMP}/out"
  : > "$out"
  TEST_LOG="$log" GITHUB_OUTPUT="$out" bash "$PARSER" >/dev/null
  local got
  got="$(grep -oE 'test_count=[0-9]+' "$out" | cut -d= -f2)"
  if [ "$got" = "$expected" ]; then
    echo "ok   - ${name} (test_count=${got})"
  else
    echo "FAIL - ${name} : attendu ${expected}, obtenu ${got:-<vide>}"
    fail=1
  fi
}

# cargo : plusieurs binaires + doctests -> somme
printf 'running 3 tests\ntest result: ok. 3 passed; 0 failed;\n   Doc-tests\ntest result: ok. 1 passed; 0 failed;\n' > "${TMP}/cargo.log"
run_case "cargo (3+1)" 4 "${TMP}/cargo.log"

# jest : doit cibler la ligne "Tests:", pas "Test Suites:"
printf 'Test Suites: 2 passed, 2 total\nTests:       12 passed, 12 total\n' > "${TMP}/jest.log"
run_case "jest (12, pas 2)" 12 "${TMP}/jest.log"

# pytest : ligne de résumé
printf '===== 7 passed, 1 skipped in 0.42s =====\n' > "${TMP}/pytest.log"
run_case "pytest (7)" 7 "${TMP}/pytest.log"

# aucun test (cas infra)
printf 'no tests\n' > "${TMP}/none.log"
run_case "aucun test" 0 "${TMP}/none.log"

# log absent -> 0
run_case "log absent" 0 "${TMP}/inexistant.log"

exit "$fail"
