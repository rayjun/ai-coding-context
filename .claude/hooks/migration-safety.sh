#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: When a DB migration / schema file is edited, remind the AI to
#          consider reversibility, backfill behavior, and online DDL concerns.
#          Non-blocking; intended to surface thinking gates before commit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Detect migration files
IS_MIGRATION=0
case "$FILE_PATH" in
  */migrations/*|*/migrate/*|*/db/migrate/*|*/schema/*) IS_MIGRATION=1 ;;
  *.sql) IS_MIGRATION=1 ;;
esac

if [ "$IS_MIGRATION" -eq 0 ]; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Sniff the content for high-risk operations
RISKS=""
if grep -qiE '\bALTER\s+TABLE\b.*\bADD\s+COLUMN\b.*\bNOT\s+NULL\b' "$FILE_PATH" 2>/dev/null && \
   ! grep -qiE '\bDEFAULT\b' "$FILE_PATH" 2>/dev/null; then
  RISKS="${RISKS}\n  - ADD COLUMN NOT NULL without DEFAULT: backfill required; may lock the table."
fi
if grep -qiE '\bDROP\s+(COLUMN|TABLE|INDEX)\b' "$FILE_PATH" 2>/dev/null; then
  RISKS="${RISKS}\n  - DROP detected: irreversible. Ensure the column/table is confirmed unused in all deployed versions."
fi
if grep -qiE '\bCREATE\s+INDEX\b' "$FILE_PATH" 2>/dev/null && \
   ! grep -qiE '\bCONCURRENTLY\b' "$FILE_PATH" 2>/dev/null; then
  RISKS="${RISKS}\n  - CREATE INDEX without CONCURRENTLY (Postgres): will block writes for the duration."
fi
if grep -qiE '\bALTER\s+TABLE\b.*\bRENAME\s+COLUMN\b' "$FILE_PATH" 2>/dev/null; then
  RISKS="${RISKS}\n  - RENAME COLUMN: coordinate with application rollout (expand/contract pattern)."
fi

# Always issue a generic reminder for migrations; append specific risks if found.
echo ""
echo "=== MIGRATION SAFETY CHECK ==="
echo "$FILE_PATH is a migration. Before committing, verify:"
echo "  1. Reversibility — does a down migration exist, or document why not?"
echo "  2. Backfill plan — if NOT NULL added, how are existing rows handled?"
echo "  3. Locking — large tables + blocking DDL = production incident."
echo "  4. Rollout order — application code must tolerate both old and new schema during deploy."
if [ -n "$RISKS" ]; then
  echo ""
  echo "Specific risks detected in this file:"
  printf "%b\n" "$RISKS"
fi
echo "=== END MIGRATION SAFETY CHECK ==="

exit 0
