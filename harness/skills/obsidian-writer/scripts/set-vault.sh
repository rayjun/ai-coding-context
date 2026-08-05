#!/usr/bin/env bash
# Persist the Obsidian vault path to ~/harness/obsidian-vault.path.
# Creates the file if missing; overwrites if present.
# Also emits a recommendation to add OBSIDIAN_VAULT_PATH to ~/harness/settings.json
# so env-based resolution works in all future sessions without disk reads.

set -euo pipefail

VAULT="${1:-}"
if [ -z "$VAULT" ]; then
  printf 'Usage: %s <absolute-vault-path>\n' "$0" >&2
  exit 2
fi

# Require absolute path
case "$VAULT" in
  /*) ;;
  *) printf 'Vault path must be absolute: %s\n' "$VAULT" >&2; exit 2 ;;
esac

# Reject if not a directory
if [ ! -d "$VAULT" ]; then
  printf 'Not a directory: %s\n' "$VAULT" >&2
  exit 2
fi

# Reject if AGENTS.md is missing at vault root — fail-close design
if [ ! -f "$VAULT/AGENTS.md" ]; then
  printf 'Vault is missing AGENTS.md at its root: %s/AGENTS.md\n' "$VAULT" >&2
  printf 'Create it first; obsidian-writer refuses to write without vault-specific rules.\n' >&2
  exit 3
fi

mkdir -p "${HOME}/.config/ai-context"
printf '%s\n' "$VAULT" > "${HOME}/harness/obsidian-vault.path.tmp"
mv "${HOME}/harness/obsidian-vault.path.tmp" "${HOME}/harness/obsidian-vault.path"

cat <<EOF
Saved vault path: $VAULT
  → ${HOME}/harness/obsidian-vault.path

Recommended: also add to ~/harness/settings.json for env-based resolution:

  {
    "env": {
      "OBSIDIAN_VAULT_PATH": "$VAULT"
    }
  }

Env resolution beats file read on every skill invocation.
EOF
