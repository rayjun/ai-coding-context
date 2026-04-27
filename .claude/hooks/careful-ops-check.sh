#!/bin/bash
# Hook: PreToolUse → Bash
# Purpose: Intercept destructive commands before execution.
# Pattern SSoT: .claude/hooks/lib/danger-patterns.sh (shared with the SKILL).
# Response format: current hookSpecificOutput API (exit 0 + stdout JSON).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/danger-patterns.sh
source "$SCRIPT_DIR/lib/danger-patterns.sh"
# shellcheck source=lib/pretool-response.sh
source "$SCRIPT_DIR/lib/pretool-response.sh"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.command)

if [ -z "$COMMAND" ]; then
  exit 0
fi

check_danger "$COMMAND"

case "$DANGER_LEVEL" in
  CRITICAL)
    emit_pretool_deny "CRITICAL: ${DANGER_REASON}  Alternative: ${DANGER_ALT}"
    exit 0
    ;;
  HIGH)
    printf 'WARNING [HIGH]: %s  Alternative: %s\n' "$DANGER_REASON" "$DANGER_ALT"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
