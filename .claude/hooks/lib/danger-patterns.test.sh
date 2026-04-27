#!/bin/bash
# Unit tests for .claude/hooks/lib/danger-patterns.sh
# Run: bash .claude/hooks/lib/danger-patterns.test.sh
set +e

source "$(dirname "$0")/danger-patterns.sh"

fail=0
run() {
  local cmd="$1" expect="$2"
  DANGER_LEVEL=""
  check_danger "$cmd"
  local actual="${DANGER_LEVEL:-none}"
  [ "$expect" = "" ] && expect="none"
  if [ "$actual" = "$expect" ]; then
    printf 'PASS  %-60s -> %s\n' "$cmd" "$actual"
  else
    printf 'FAIL  %-60s expected=%s actual=%s\n' "$cmd" "$expect" "$actual"
    fail=1
  fi
}

R='rm'
RR="$R -rf"

run "ls -la"                                      ""
run "$RR /tmp/foo"                                "CRITICAL"
run '$R -rf $FOO/'                                ""   # rm literal missing — sanity
run "$RR \$FOO/"                                  "CRITICAL"
run "$RR \${FOO}/"                                "CRITICAL"
run "$RR \"\$FOO/file\""                          "CRITICAL"
run "$RR \"\${HOME}/tmp/x\""                      "CRITICAL"
run "$RR \${FOO:?err}/"                           "CRITICAL"   # still CRITICAL: -rf literal
run "$R -r \${FOO:?err}/"                         ""           # -r (no -f) + :? guard → OK
run "$R -f \"\$SESS/test-evidence\""              ""
run "$R -f \"\$SESS/test-evidence\" && echo ok"   ""
run "SESS=\$(./bin); $R -f \"\$SESS/file\""       ""
run "DROP TABLE users"                            "CRITICAL"
run "DELETE FROM users"                           "CRITICAL"
run "DELETE FROM users WHERE id=1"                ""
run "UPDATE users SET name='x'"                   "CRITICAL"
run "UPDATE users SET name='x' WHERE id=1"        ""
run "git reset --hard HEAD"                       "HIGH"
run "git push --force"                            "HIGH"
run "git push --force-with-lease"                 ""
run "git rebase -i HEAD~3"                        "HIGH"
run "kubectl delete pod foo"                      "HIGH"
run "kubectl delete pod -n production foo"        "CRITICAL"
run "docker system prune -a"                      "HIGH"
run "echo hello"                                  ""

exit $fail
