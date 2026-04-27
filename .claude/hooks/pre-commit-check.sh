#!/bin/bash
# Hook: PreToolUse → Bash
# Purpose: Block git commit when there is no test evidence newer than the
#          most recent source-code change.
#
# Mechanism:
#   PostToolUse 侧（record-test-evidence.sh）在测试/构建/lint 命令输出看起来成功时才写 evidence。
#   PreToolUse 这里比对 evidence mtime 与 "最近源码改动" mtime。
#   只要源码在最近一次绿灯测试之后又被改过，就要求重跑测试。
#
# Response format: current hookSpecificOutput API.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh")
EVIDENCE_FILE="$SESSION_DIR/test-evidence"

# shellcheck source=lib/pretool-response.sh
source "$SCRIPT_DIR/lib/pretool-response.sh"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.command)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only gate git commit
if ! echo "$COMMAND" | grep -qE '(^|;|\&\&|\|\|?\s*)git\s+commit\b'; then
  exit 0
fi

# Skip --amend when the amendment adds nothing (e.g. doc-only / config)
# (kept permissive; users can --amend if they know what they're doing)

# --- Gate: require evidence file ---
if [ ! -f "$EVIDENCE_FILE" ]; then
  emit_pretool_deny "No test evidence in this session. AGENTS.md §6 Step 7 requires verification before commit. Run your project's test suite first (e.g. \`cargo test\`, \`go test ./...\`, \`npm test\`, \`pytest\`). Evidence is recorded only when the command output looks clean (no FAIL/ERROR markers)."
  exit 0
fi

# --- Gate: evidence must be newer than latest source edit ---
file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

EVIDENCE_MTIME=$(file_mtime "$EVIDENCE_FILE")

if git rev-parse --is-inside-work-tree &>/dev/null; then
  NEWEST_SRC=$(git ls-files -co --exclude-standard 2>/dev/null \
    | grep -vE '(^|/)(docs/|\.git/|node_modules/|target/|dist/|build/)' \
    | grep -vE '\.(md|txt|lock|bak)$' \
    | grep -vE '(^|/)docs/STATUS\.md$' \
    | xargs -I{} stat -f '%m %N' {} 2>/dev/null \
    | sort -nr | head -1 | awk '{print $1}')

  NEWEST_SRC=${NEWEST_SRC:-0}

  if [ "$NEWEST_SRC" -gt "$EVIDENCE_MTIME" ]; then
    emit_pretool_deny "Source files have been modified since the last successful test run (evidence=${EVIDENCE_MTIME}, newest source=${NEWEST_SRC}). Re-run your test suite before committing."
    exit 0
  fi
fi

exit 0
