#!/bin/bash
# Hook: Notification
# Purpose: Alert user via system notification when a long-running task completes
# or when Claude needs user attention.
#
# Works on macOS (osascript) and Linux (notify-send).
# Falls back to terminal bell if neither is available.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)

# Extract message via shared JSON parser
MESSAGE=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" message 2>/dev/null || true)

if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude Code needs your attention"
fi

# Try macOS notification (safe: pass message via argv, not string interpolation)
if command -v osascript &>/dev/null; then
  osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "Claude Code"' -e 'end run' -- "$MESSAGE" 2>/dev/null || true
  exit 0
fi

# Try Linux notification
if command -v notify-send &>/dev/null; then
  notify-send "Claude Code" "$MESSAGE" 2>/dev/null || true
  exit 0
fi

# Fallback: terminal bell
printf '\a'
exit 0
