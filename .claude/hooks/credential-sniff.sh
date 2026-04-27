#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Scan edited file content for inline credentials (API keys, private
#          keys, tokens). The permissions.deny rule only blocks .env* files —
#          this catches inline leaks into regular source files.
#
# Non-blocking: always exits 0 with a warning. Blocking would be too risky
# (high false-positive rate against test fixtures and example docs).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip known-safe contexts. NOTE: this script must skip itself by basename
# check because its own content triggers the patterns.
BASENAME=$(basename "$FILE_PATH")
case "$FILE_PATH" in
  */fixtures/*|*/testdata/*|*.example.*|*.sample.*|*.lock)
    exit 0
    ;;
esac
case "$BASENAME" in
  credential-sniff.sh) exit 0 ;;
esac

# Known patterns for live credentials.
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                           # AWS Access Key ID
  'sk-(proj-)?[A-Za-z0-9_\-]{20,}'                             # OpenAI / Anthropic-style
  'xox[baprs]-[A-Za-z0-9\-]{10,}'                              # Slack tokens
  'ghp_[A-Za-z0-9]{30,}'                                       # GitHub PAT
  'github_pat_[A-Za-z0-9_]{20,}'                               # GitHub fine-grained PAT
  'AIza[0-9A-Za-z\-_]{30,}'                                    # Google API key
  '-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----'  # PEM private key
  'eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}'  # JWT
)

MATCHES=""
for pat in "${PATTERNS[@]}"; do
  if grep -Eqn "$pat" "$FILE_PATH" 2>/dev/null; then
    LINE=$(grep -En "$pat" "$FILE_PATH" 2>/dev/null | head -1)
    MATCHES="${MATCHES}\n  - $LINE"
  fi
done

if [ -n "$MATCHES" ]; then
  echo ""
  echo "=== CREDENTIAL SCAN WARNING ==="
  echo "$FILE_PATH looks like it contains inline credentials:"
  printf "%b\n" "$MATCHES"
  echo "If this is intentional test data, rename to *.example.* / *.sample.* or move under fixtures/."
  echo "Otherwise move the value to an env var and rotate the credential — it may be compromised."
  echo "=== END CREDENTIAL SCAN ==="
fi

exit 0
