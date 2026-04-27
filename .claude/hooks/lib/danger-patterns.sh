#!/bin/bash
# Shared source: destructive command detection patterns.
# Used by .claude/hooks/careful-ops-check.sh and referenced by
# .claude/skills/careful-ops/SKILL.md. Single source of truth.
#
# Usage:
#   source .claude/hooks/lib/danger-patterns.sh
#   check_danger "$COMMAND"
#   # Sets:
#   #   DANGER_LEVEL   = CRITICAL | HIGH | ""
#   #   DANGER_REASON  = human-readable reason
#   #   DANGER_ALT     = safer alternative

# shellcheck shell=bash

check_danger() {
  local cmd="$1"
  DANGER_LEVEL=""
  DANGER_REASON=""
  DANGER_ALT=""

  # Split on statement separators so we check each clause independently.
  # Avoids false positives where one clause has `$VAR` and another has `rm -rf`
  # but neither individually is dangerous.
  local IFS=$'\n'
  local statements
  statements=$(printf '%s' "$cmd" | awk '{
    gsub(/&&/, "\n"); gsub(/\|\|/, "\n"); gsub(/;/, "\n"); gsub(/\|/, "\n");
    print
  }')

  local stmt
  while IFS= read -r stmt; do
    [ -z "$stmt" ] && continue
    _check_statement "$stmt"
    [ -n "$DANGER_LEVEL" ] && return 0
  done <<<"$statements"

  return 0
}

_check_statement() {
  local cmd="$1"
  DANGER_LEVEL=""
  DANGER_REASON=""
  DANGER_ALT=""

  # --- CRITICAL ---

  # rm -r/-rf cases. Two sub-rules:
  # (1) With ANY shell variable `$VAR` or `${VAR}` without a `:?` guard —
  #     quoting doesn't prevent the "empty variable → / root" trap.
  # (2) With a literal path — still destructive, warn.
  # Skip the variable rule if a `:?` guard is present.
  if echo "$cmd" | grep -qE '\brm\b' && \
     echo "$cmd" | grep -qE '(-r\b|-R\b|--recursive\b|-[a-zA-Z]*r[a-zA-Z]*\b)'; then
    if echo "$cmd" | grep -qE '\$\{?[A-Za-z_][A-Za-z0-9_]*' && \
       ! echo "$cmd" | grep -qE '\$\{[A-Za-z_][A-Za-z0-9_]*:\?'; then
      DANGER_LEVEL="CRITICAL"
      DANGER_REASON="rm -r/-rf with a shell variable. If the variable is unset or empty, the command may delete unintended paths (quoting alone does not protect)."
      DANGER_ALT="Use \${VAR:?unset} to fail fast on empty, or hardcode the path."
      return 0
    fi
    if echo "$cmd" | grep -qE '(-f\b|--force\b|-[a-zA-Z]*f[a-zA-Z]*\b)'; then
      DANGER_LEVEL="CRITICAL"
      DANGER_REASON="\`rm -rf\` with literal path detected. Irreversible."
      DANGER_ALT="Verify with \`ls\` first; consider \`trash-put\` or moving to a backup location."
      return 0
    fi
  fi

  # rm -rf (literal)
  # Handled by the combined rule above.

  # DROP TABLE / DROP DATABASE
  if echo "$cmd" | grep -qiE '\bDROP\s+(TABLE|DATABASE)\b'; then
    DANGER_LEVEL="CRITICAL"
    DANGER_REASON="\`DROP TABLE/DATABASE\` detected. Permanently deletes data."
    DANGER_ALT="Back up first with \`pg_dump\` or \`mysqldump\`, then proceed manually."
    return 0
  fi

  # TRUNCATE
  if echo "$cmd" | grep -qiE '\bTRUNCATE\b'; then
    DANGER_LEVEL="CRITICAL"
    DANGER_REASON="\`TRUNCATE\` detected. Removes all rows irreversibly."
    DANGER_ALT="Verify the table name and row count. Consider soft-delete or a backup first."
    return 0
  fi

  # DELETE without WHERE
  if echo "$cmd" | grep -qiE '\bDELETE\s+FROM\b' && ! echo "$cmd" | grep -qiE '\bWHERE\b'; then
    DANGER_LEVEL="CRITICAL"
    DANGER_REASON="\`DELETE\` without \`WHERE\` detected. Affects all rows."
    DANGER_ALT="Add a WHERE clause. Run a SELECT first to confirm scope."
    return 0
  fi

  # UPDATE without WHERE
  if echo "$cmd" | grep -qiE '\bUPDATE\s+\S+\s+SET\b' && ! echo "$cmd" | grep -qiE '\bWHERE\b'; then
    DANGER_LEVEL="CRITICAL"
    DANGER_REASON="\`UPDATE\` without \`WHERE\` detected. Affects all rows."
    DANGER_ALT="Add a WHERE clause. Run a SELECT first to confirm scope."
    return 0
  fi

  # kubectl delete targeting production namespace
  if echo "$cmd" | grep -qE '\bkubectl\s+delete\b.*(prod|production)\b'; then
    DANGER_LEVEL="CRITICAL"
    DANGER_REASON="\`kubectl delete\` against a production namespace."
    DANGER_ALT="Run \`kubectl get\` first and use \`--dry-run=client\` to preview."
    return 0
  fi

  # --- HIGH ---

  # git reset --hard
  if echo "$cmd" | grep -qE '\bgit\s+reset\s+--hard\b'; then
    DANGER_LEVEL="HIGH"
    DANGER_REASON="\`git reset --hard\` discards uncommitted changes permanently."
    DANGER_ALT="\`git stash\` first, or create a backup branch."
    return 0
  fi

  # git push --force (but NOT --force-with-lease)
  if echo "$cmd" | grep -qE '\bgit\s+push\b.*--force\b' && ! echo "$cmd" | grep -qE -- '--force-with-lease'; then
    DANGER_LEVEL="HIGH"
    DANGER_REASON="\`git push --force\` can overwrite others' work."
    DANGER_ALT="Use \`git push --force-with-lease\`."
    return 0
  fi

  # git rebase
  if echo "$cmd" | grep -qE '\bgit\s+rebase\b'; then
    DANGER_LEVEL="HIGH"
    DANGER_REASON="\`git rebase\` rewrites history. Dangerous on pushed branches."
    DANGER_ALT="Use \`git merge\` to preserve history on pushed branches."
    return 0
  fi

  # kubectl delete (non-prod)
  if echo "$cmd" | grep -qE '\bkubectl\s+delete\b'; then
    DANGER_LEVEL="HIGH"
    DANGER_REASON="\`kubectl delete\` removes cluster resources."
    DANGER_ALT="Run \`kubectl get\` first; use \`--dry-run=client\` to preview."
    return 0
  fi

  # docker system prune
  if echo "$cmd" | grep -qE '\bdocker\s+system\s+prune\b'; then
    DANGER_LEVEL="HIGH"
    DANGER_REASON="\`docker system prune\` removes all unused data."
    DANGER_ALT="Run \`docker ps\` and \`docker images\` first to review."
    return 0
  fi

  return 0
}
