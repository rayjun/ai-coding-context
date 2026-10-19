# AI Coding Context — a long-running task harness

> The hard part of AI coding is not writing code. It is keeping an agent on track across hours of work, context compactions, and multiple sessions.

A minimal, tool-agnostic harness for AI coding agents (Claude Code, Codex, Gemini CLI, Hermes, …). It gives an agent the things it cannot do reliably on its own:

- **Durable state** — `docs/tasks.json` + `docs/STATUS.md` + git commits. A brand-new agent can resume from files alone.
- **Drift & failure control** — bounded loops (goal → signal → hypothesis → exit/stop), evidence-before-assertion, anti-spiral escalation.
- **Safety gates** — destructive-operation interception, commit evidence gate, unattended-operation rules.
- **Cross-agent review** — what a review request must carry and the principles the reviewer works by (self-contained, evidence-first, blocker triage).

**Evaluation criterion**: every file here must answer one question — *does it help an agent execute a long-running task?* Everything that did not was removed (see `git log` for the earlier, fuller framework).

## Install

From your project root:

```bash
curl -sSL https://raw.githubusercontent.com/rayjun/ai-coding-context/main/install.sh | bash
```

Dry run: append `--dry-run`. Existing files are backed up to `.bak`; a failed sync rolls back.

## What you get

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | The long-task protocol: state files, loop discipline, evidence, safety triggers, cross-agent review |
| `harness/hooks/` | Self-executed check scripts + shared libs (trigger table in AGENTS.md §5) |
| `harness/hooks/lib/danger-patterns.sh` | SSoT for destructive-command patterns, with 25-case test |
| `docs/STATUS.template.md` | Template for the session-state file |
| `docs/tasks.example.json` | Example task SSoT |
| `install.sh` | Syncs this harness into an existing project (backups to `.bak`) |

## Tests

```bash
make test
```

Runs: `danger-patterns.test.sh` (pattern table), `pre-commit-check.test.sh`, `record-test-evidence.test.sh`.

## Design notes

- **Self-executed, not platform-registered**: hooks are plain scripts the agent runs at the moments listed in AGENTS.md §5. That is what keeps the harness working across tools.
- **State over context**: long tasks survive compactions by persisting intent to disk, not by remembering.
- **Evidence over assertions**: "it works" is only valid with command output attached.
