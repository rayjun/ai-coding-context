#!/bin/bash
# Hook: Stop (session-end companion to session-end.sh)
# Purpose: Warn when the AI claimed tests passed / code verified without
#          a corresponding successful Bash test command recorded via
#          .claude/hooks/record-test-evidence.sh in the same session.
#
# This enforces §6 Step 7 "evidence before assertions" at session close.
# Non-blocking.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh" 2>/dev/null || echo "")
EVIDENCE_FILE="${SESSION_DIR:-/tmp}/test-evidence"

# Stop hook receives JSON with session transcript path or chunk.
INPUT=$(cat || true)

# Try to pull transcript_path (Claude Code) first, fall back to reading stdin.
TRANSCRIPT_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" transcript_path 2>/dev/null || true)

TEXT=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  TEXT=$(tail -c 200000 "$TRANSCRIPT_PATH" 2>/dev/null || true)
else
  TEXT="$INPUT"
fi

# Look for success-assertion phrases in the tail of the conversation.
# Keep the list small and specific to avoid noisy false positives.
CLAIM_PATTERN='(测试通过|全部通过|验证通过|all tests pass(ed)?|tests? passed|verified successfully|lgtm|looks good|ready to (ship|merge|commit))'

if ! echo "$TEXT" | grep -qiE "$CLAIM_PATTERN"; then
  exit 0
fi

# If we have evidence file with any successful test command recorded, we're fine.
if [ -f "$EVIDENCE_FILE" ] && [ -s "$EVIDENCE_FILE" ]; then
  exit 0
fi

echo ""
echo "=== ASSERTION-EVIDENCE AUDIT ==="
echo "Transcript contains test / verification claims but no successful test command"
echo "was recorded in this session (evidence file empty: $EVIDENCE_FILE)."
echo ""
echo "Claim examples found in the conversation tail:"
echo "$TEXT" | grep -iE "$CLAIM_PATTERN" | head -3 | sed 's/^/  > /'
echo ""
echo "Per AGENTS.md §6 Step 7: evidence before assertions. Do not claim tests pass"
echo "unless a test command actually ran and exited 0."
echo "=== END AUDIT ==="
exit 0
