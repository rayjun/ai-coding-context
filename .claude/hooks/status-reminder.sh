#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Remind to update docs/STATUS.md after editing source files.
# Only triggers for non-docs files to avoid nagging while editing documentation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

# If we can't extract a file path, skip
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip if the edited file is under docs/ (avoid reminding while editing docs)
if echo "$FILE_PATH" | grep -qE '(^|/)docs/'; then
  exit 0
fi

# Skip common non-source files that don't warrant a STATUS.md update
if echo "$FILE_PATH" | grep -qE '\.(md|txt|json|yaml|yml|toml|lock)$'; then
  exit 0
fi

# Check if STATUS.md has been modified in the current uncommitted changes
if git rev-parse --is-inside-work-tree &>/dev/null; then
  if git diff --name-only 2>/dev/null | grep -q 'docs/STATUS.md'; then
    exit 0
  fi
  if git diff --cached --name-only 2>/dev/null | grep -q 'docs/STATUS.md'; then
    exit 0
  fi
fi

echo "Reminder: You've edited source files. Consider updating docs/STATUS.md to reflect the current project state."
exit 0
