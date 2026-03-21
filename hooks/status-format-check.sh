#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: After STATUS.md is edited, validate it has all required sections.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

# Only check STATUS.md
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if ! echo "$FILE_PATH" | grep -qE '(^|/)docs/STATUS\.md$'; then
  exit 0
fi

if [ ! -f "docs/STATUS.md" ]; then
  exit 0
fi

MISSING=""

grep -q '## 当前目标' "docs/STATUS.md" || MISSING="${MISSING}\n  - '## 当前目标' (Current Goal)"
grep -q '## 任务进度' "docs/STATUS.md" || MISSING="${MISSING}\n  - '## 任务进度' (Task Progress)"
grep -q '## 下次从这里开始' "docs/STATUS.md" || MISSING="${MISSING}\n  - '## 下次从这里开始' (Resume Point)"

if [ -n "$MISSING" ]; then
  echo -e "STATUS.md format check FAILED. Missing required sections:${MISSING}"
  echo "These sections are needed for cross-session continuity. Add them now."
fi

# Check that resume section is not empty
RESUME_LINE=$(grep -n '## 下次从这里开始' "docs/STATUS.md" 2>/dev/null | head -1 | cut -d: -f1 || true)
if [ -n "$RESUME_LINE" ]; then
  CONTENT_AFTER=$(tail -n +"$((RESUME_LINE + 1))" "docs/STATUS.md" | sed '/^## /,$d' | grep -cvE '^\s*$' || true)
  if [ "$CONTENT_AFTER" -eq 0 ] 2>/dev/null; then
    echo "WARNING: '## 下次从这里开始' section is empty. Write specific instructions for the next session to resume."
  fi
fi

exit 0
