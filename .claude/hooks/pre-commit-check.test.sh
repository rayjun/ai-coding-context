#!/bin/bash
# Tests for pre-commit-check.sh
# Run: bash .claude/hooks/pre-commit-check.test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0; FAIL=0
HOOK="$SCRIPT_DIR/pre-commit-check.sh"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR" && git init -q . && git config user.email "t@t.com" && git config user.name "T"
EVIDENCE="$TMPDIR/test-evidence.abcdef123456"

run() {
  local cmd="$1" mode="$2"
  mkdir -p src
  case "$mode" in
    absent) rm -f "$EVIDENCE" ;;
    present) echo "2024-01-01T00:00:00Z cargo test" > "$EVIDENCE"; touch -t 209901010000 "$EVIDENCE" ;;
    stale)  echo "2024-01-01T00:00:00Z cargo test" > "$EVIDENCE"; touch -t 200001010000 "$EVIDENCE" ;;
  esac
  echo "fn main() {}" > src/main.rs; git add src/main.rs 2>/dev/null
  local input=$(jq -n --arg cmd "$cmd" --arg sid "abcdef1234567890" '{tool_input:{command:$cmd},session_id:$sid}')
  HERMES_HOOK_EVIDENCE_DIR="$TMPDIR" bash -c 'echo "$1" | bash "$2"' _ "$input" "$HOOK" 2>/dev/null || true
}

OUT=$(run "cargo build" absent)
echo "$OUT" | grep -q 'permissionDecision.*deny' && { echo "FAIL: non-commit denied"; FAIL=$((FAIL+1)); } || { echo "PASS: non-commit allowed"; PASS=$((PASS+1)); }

OUT=$(run "git commit -m x" absent)
echo "$OUT" | grep -q 'permissionDecision.*deny' && { echo "PASS: commit w/o evidence denied"; PASS=$((PASS+1)); } || { echo "FAIL: commit w/o evidence not denied"; FAIL=$((FAIL+1)); }

OUT=$(run "git commit -m x" present)
echo "$OUT" | grep -q 'permissionDecision.*deny' && { echo "FAIL: commit w/ fresh evidence denied"; FAIL=$((FAIL+1)); } || { echo "PASS: commit w/ fresh evidence allowed"; PASS=$((PASS+1)); }

OUT=$(run "git commit -m x" stale)
echo "$OUT" | grep -q 'permissionDecision.*deny' && { echo "PASS: commit w/ stale evidence denied"; PASS=$((PASS+1)); } || { echo "FAIL: commit w/ stale evidence not denied"; FAIL=$((FAIL+1)); }

echo "Results: $PASS passed, $FAIL failed"
exit $FAIL