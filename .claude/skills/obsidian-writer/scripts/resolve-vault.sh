#!/usr/bin/env bash
# Resolve the Obsidian vault path.
# Priority:
#   1. OBSIDIAN_VAULT_PATH env var (set in ~/.claude/settings.json env)
#   2. ~/.claude/obsidian-vault.path file (written by bootstrap flow)
# On success: prints the absolute vault path to stdout, exit 0.
# On failure: prints a marker to stderr, exit 1 (caller must bootstrap).

set -euo pipefail

if [ -n "${OBSIDIAN_VAULT_PATH:-}" ]; then
  if [ -d "$OBSIDIAN_VAULT_PATH" ]; then
    printf '%s\n' "$OBSIDIAN_VAULT_PATH"
    exit 0
  else
    printf 'OBSIDIAN_VAULT_PATH is set but not a directory: %s\n' "$OBSIDIAN_VAULT_PATH" >&2
    exit 1
  fi
fi

PATH_FILE="${HOME}/.claude/obsidian-vault.path"
if [ -f "$PATH_FILE" ]; then
  VAULT=$(head -1 "$PATH_FILE" | tr -d '\n\r ')
  if [ -n "$VAULT" ] && [ -d "$VAULT" ]; then
    printf '%s\n' "$VAULT"
    exit 0
  fi
fi

printf 'vault-path-not-set\n' >&2
exit 1
