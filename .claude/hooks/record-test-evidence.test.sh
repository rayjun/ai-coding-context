#!/bin/bash
# Tests for record-test-evidence.sh
# Run: cd .claude/hooks && bash record-test-evidence.test.sh

set -euo pipefail

PASS=0; FAIL=0
HOOK="$(pwd)/record-test-evidence.sh"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

EVIDENCE="$TMPDIR/test-evidence.test12345678"

run() {
  local cmd="$1" interrupted="${2:-false}" stdout="${3:-}" stderr="${4:-}"
  rm -f "$EVIDENCE"
  local input
  input=$(jq -n --arg cmd "$cmd" --arg int "$interrupted" --arg out "$stdout" --arg err "$stderr" \
    '{tool_input:{command:$cmd},tool_response:{interrupted:$int,stdout:$out,stderr:$err},session_id:"test1234567890"}')
  HERMES_HOOK_EVIDENCE_DIR="$TMPDIR" bash -c 'echo "$1" | bash "$2"' _ "$input" "$HOOK" 2>/dev/null || true
  [ -f "$EVIDENCE" ] && echo "RECORDED" || echo "NOT_RECORDED"
}

# Test 1: Successful test → recorded
RESULT=$(run "cargo test" "false" "running 5 tests\n5 passed" "")
[ "$RESULT" = "RECORDED" ] && { echo "PASS: successful test recorded"; PASS=$((PASS+1)); } || { echo "FAIL: successful test should be recorded"; FAIL=$((FAIL+1)); }

# Test 2: Failed test → NOT recorded
RESULT=$(run "cargo test" "false" "running 5 tests\n2 FAILED" "")
[ "$RESULT" = "NOT_RECORDED" ] && { echo "PASS: failed test not recorded"; PASS=$((PASS+1)); } || { echo "FAIL: failed test should NOT be recorded"; FAIL=$((FAIL+1)); }

# Test 3: Interrupted → NOT recorded
RESULT=$(run "cargo test" "true" "running..." "")
[ "$RESULT" = "NOT_RECORDED" ] && { echo "PASS: interrupted not recorded"; PASS=$((PASS+1)); } || { echo "FAIL: interrupted should NOT be recorded"; FAIL=$((FAIL+1)); }

# Test 4: Non-test command (echo) → NOT recorded
RESULT=$(run "echo 'cargo test done'" "false" "" "")
[ "$RESULT" = "NOT_RECORDED" ] && { echo "PASS: echo not recorded"; PASS=$((PASS+1)); } || { echo "FAIL: echo should NOT be recorded"; FAIL=$((FAIL+1)); }

# Test 5: Build command → recorded
RESULT=$(run "cargo build" "false" "Compiling..." "")
[ "$RESULT" = "RECORDED" ] && { echo "PASS: successful build recorded"; PASS=$((PASS+1)); } || { echo "FAIL: successful build should be recorded"; FAIL=$((FAIL+1)); }

# Test 6: "0 failed" → not a failure
RESULT=$(run "cargo test" "false" "test result: ok. 10 passed; 0 failed" "")
[ "$RESULT" = "RECORDED" ] && { echo "PASS: '0 failed' not treated as failure"; PASS=$((PASS+1)); } || { echo "FAIL: '0 failed' should allow recording"; FAIL=$((FAIL+1)); }

echo "Results: $PASS passed, $FAIL failed"
exit $FAIL