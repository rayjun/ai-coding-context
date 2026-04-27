#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Single dispatcher for post-edit checks.
# Replaces separate entries for status-reminder + status-format-check + tasks-validate,
# avoiding 3× cold-start overhead per edit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Preserve stdin for each downstream script (they each read it afresh).
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

run_with_input() {
  # Run a script, passing the original hook JSON on stdin.
  # Non-blocking: we collect stdout/stderr but never fail the dispatcher.
  local script="$1"
  if [ -x "$script" ]; then
    echo "$INPUT" | "$script" || true
  fi
}

# 1. tasks.json validator — only fires if the edited file is docs/tasks.json
if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | grep -qE '(^|/)docs/tasks\.json$'; then
  run_with_input "$SCRIPT_DIR/tasks-validate.sh"
fi

# 2. STATUS.md format check — only fires if the edited file is docs/STATUS.md
if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | grep -qE '(^|/)docs/STATUS\.md$'; then
  run_with_input "$SCRIPT_DIR/status-format-check.sh"
fi

# 3. STATUS.md update reminder — fires when source files (non-docs) are edited
run_with_input "$SCRIPT_DIR/status-reminder.sh"

exit 0
