#!/bin/bash
# Unit tests for .claude/hooks/plan-review-reminder.sh
# Run: bash .claude/hooks/plan-review-reminder.test.sh
set +e

SCRIPT="$(cd "$(dirname "$0")" && pwd)/plan-review-reminder.sh"

fail=0
run() {
  local label="$1" file_path="$2" expect_match="$3"
  local input out
  input=$(printf '{"tool_input":{"file_path":"%s"}}' "$file_path")
  out=$(echo "$input" | bash "$SCRIPT" 2>&1)
  if [ -z "$expect_match" ]; then
    if [ -z "$out" ]; then
      printf 'PASS  %-50s -> silent\n' "$label"
    else
      printf 'FAIL  %-50s expected=silent got=%s\n' "$label" "$out"
      fail=1
    fi
  else
    if echo "$out" | grep -q "$expect_match"; then
      printf 'PASS  %-50s -> matched %s\n' "$label" "$expect_match"
    else
      printf 'FAIL  %-50s expected=%s got=%s\n' "$label" "$expect_match" "$out"
      fail=1
    fi
  fi
}

run "plan file triggers reminder"   "docs/plans/round10-p0.md"  "plan-reviewer"
run "absolute plan path"            "/repo/docs/plans/x.md"     "plan-reviewer"
run "non-plan md silent"            "docs/STATUS.md"            ""
run "source file silent"            ".claude/hooks/foo.sh"      ""
run "empty path silent"             ""                          ""
run "plan without md silent"        "docs/plans/notes.txt"      ""

if [ "$fail" -eq 0 ]; then
  echo "All plan-review-reminder tests PASS"
else
  echo "FAIL: plan-review-reminder tests"
  exit 1
fi
