#!/bin/bash
# Hook: PreToolUse → Bash
# Purpose: Intercept destructive commands before execution.
# Based on skills/careful-ops/SKILL.md danger checklist.
#
# Exit codes:
#   0 = allow (with optional warning via stdout)
#   2 = deny  (stdout JSON becomes the reason shown to the user)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read tool input from stdin, extract command via robust JSON parser
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.command)

# If we can't extract a command, allow
if [ -z "$COMMAND" ]; then
  exit 0
fi

# --- CRITICAL level: deny execution (exit 2) ---

# rm with recursive + force (handles: rm -rf, rm -r -f, rm --recursive --force, etc.)
if echo "$COMMAND" | grep -qE '\brm\b' && \
   echo "$COMMAND" | grep -qE '(-r\b|-R\b|--recursive\b|-[a-zA-Z]*r[a-zA-Z]*\b)' && \
   echo "$COMMAND" | grep -qE '(-f\b|--force\b|-[a-zA-Z]*f[a-zA-Z]*\b)'; then
  cat <<'EOF'
{"decision":"deny","reason":"CRITICAL: `rm -rf` detected. This is an irreversible destructive operation.","alternative":"Use `ls` to verify the path first, or consider `trash-put` / moving to a backup location."}
EOF
  exit 2
fi

# DROP TABLE / DROP DATABASE
if echo "$COMMAND" | grep -qiE '\bDROP\s+(TABLE|DATABASE)\b'; then
  cat <<'EOF'
{"decision":"deny","reason":"CRITICAL: `DROP TABLE/DATABASE` detected. This permanently deletes data.","alternative":"Create a backup first with `pg_dump` or `mysqldump`, then proceed manually."}
EOF
  exit 2
fi

# TRUNCATE
if echo "$COMMAND" | grep -qiE '\bTRUNCATE\b'; then
  cat <<'EOF'
{"decision":"deny","reason":"CRITICAL: `TRUNCATE` detected. This removes all rows irreversibly.","alternative":"Verify the table name and row count first. Consider soft-delete or backup before truncating."}
EOF
  exit 2
fi

# DELETE without WHERE
if echo "$COMMAND" | grep -qiE '\bDELETE\s+FROM\b' && ! echo "$COMMAND" | grep -qiE '\bWHERE\b'; then
  cat <<'EOF'
{"decision":"deny","reason":"CRITICAL: `DELETE` without `WHERE` clause detected. This deletes ALL rows.","alternative":"Add a WHERE clause to limit scope. Run a SELECT first to confirm the affected rows."}
EOF
  exit 2
fi

# UPDATE without WHERE
if echo "$COMMAND" | grep -qiE '\bUPDATE\s+\S+\s+SET\b' && ! echo "$COMMAND" | grep -qiE '\bWHERE\b'; then
  cat <<'EOF'
{"decision":"deny","reason":"CRITICAL: `UPDATE` without `WHERE` clause detected. This updates ALL rows.","alternative":"Add a WHERE clause to limit scope. Run a SELECT first to confirm the affected rows."}
EOF
  exit 2
fi

# --- HIGH level: warn but allow (exit 0 with message) ---

# git reset --hard
if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  echo "WARNING [HIGH]: \`git reset --hard\` discards uncommitted changes permanently. Consider \`git stash\` or creating a backup branch first."
  exit 0
fi

# git push --force (but NOT --force-with-lease)
if echo "$COMMAND" | grep -qE '\bgit\s+push\b.*--force\b' && ! echo "$COMMAND" | grep -qE '--force-with-lease'; then
  echo "WARNING [HIGH]: \`git push --force\` can overwrite others' work. Use \`git push --force-with-lease\` instead."
  exit 0
fi

# git rebase (general warning for pushed branches)
if echo "$COMMAND" | grep -qE '\bgit\s+rebase\b'; then
  echo "WARNING [HIGH]: \`git rebase\` rewrites history. If this branch is already pushed, consider \`git merge\` to preserve history."
  exit 0
fi

# kubectl delete
if echo "$COMMAND" | grep -qE '\bkubectl\s+delete\b'; then
  echo "WARNING [HIGH]: \`kubectl delete\` removes cluster resources. Run \`kubectl get\` first to verify, and use \`--dry-run=client\` to preview."
  exit 0
fi

# docker system prune
if echo "$COMMAND" | grep -qE '\bdocker\s+system\s+prune\b'; then
  echo "WARNING [HIGH]: \`docker system prune\` removes all unused data. Run \`docker ps\` and \`docker images\` first to review."
  exit 0
fi

# No dangerous operation detected
exit 0
