#!/bin/bash
set -euo pipefail
# Hook: PostToolUse (all tools)
# Purpose: Every N tool invocations, remind AI to check the plan.
# Counter is session-scoped via lib/counter-path.sh — fresh sessions
# start at 0 instead of inheriting a cross-session running total.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/counter-path.sh
source "$SCRIPT_DIR/lib/counter-path.sh"

INPUT=$(cat)
COUNTER_FILE=$(counter_path_for_input "$INPUT" "drift-counter")

# Read current counter
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  if ! echo "$COUNT" | grep -qE '^[0-9]+$'; then
    COUNT=0
  fi
else
  COUNT=0
fi

COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE.tmp" && mv "$COUNTER_FILE.tmp" "$COUNTER_FILE"

# Every 30 tool calls, output a reminder
if [ $((COUNT % 30)) -eq 0 ]; then
  echo ""
  echo "=== DRIFT CHECK (${COUNT} tool calls in this session) ==="
  echo "You have made ${COUNT} tool invocations."
  echo "Pause and verify:"
  echo "  1. Are you still aligned with the plan in docs/plans/?"
  echo "  2. Check docs/tasks.json — are you working on the right task?"
  echo "  3. Have you updated docs/STATUS.md recently?"
  echo "If you've been debugging the same issue for a while, step back and reconsider your approach."
  echo "=== END DRIFT CHECK ==="
  echo ""
fi

exit 0
