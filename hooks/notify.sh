#!/bin/bash
# Hook: Notification
# Purpose: Alert user via system notification when a long-running task completes
# or when Claude needs user attention.
#
# Works on macOS (osascript) and Linux (notify-send).
# Falls back to terminal bell if neither is available.

set -euo pipefail

INPUT=$(cat)

# Extract message if provided
MESSAGE=$(echo "$INPUT" | grep -o '"message"\s*:\s*"[^"]*"' | head -1 | sed 's/"message"\s*:\s*"//;s/"$//' || true)

if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude Code needs your attention"
fi

# Try macOS notification
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" 2>/dev/null || true
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
