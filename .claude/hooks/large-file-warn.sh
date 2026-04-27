#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Warn when a single file exceeds a size threshold. AI tends to
#          generate one large file when splitting is healthier. Non-blocking.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip generated / vendored / data files
case "$FILE_PATH" in
  *.lock|*.min.*|*/node_modules/*|*/vendor/*|*/dist/*|*/build/*|*.json|*.yaml|*.yml|*.csv|*.tsv)
    exit 0
    ;;
esac

THRESHOLD=${CLAUDE_LARGE_FILE_THRESHOLD:-1500}
LINES=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)

if [ "$LINES" -gt "$THRESHOLD" ]; then
  echo ""
  echo "=== LARGE FILE WARNING ==="
  echo "$FILE_PATH is $LINES lines (threshold $THRESHOLD)."
  echo "Consider whether the file should be split into smaller modules. Large single files"
  echo "often indicate missing abstraction boundaries — a common AI-generated anti-pattern."
  echo "Override threshold via CLAUDE_LARGE_FILE_THRESHOLD env var."
  echo "=== END LARGE FILE WARNING ==="
fi

exit 0
