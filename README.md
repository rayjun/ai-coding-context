# AI Coding Context

> The essence of AI Coding is **Context Management**. This project establishes a balance between the probability of LLMs and the certainty of software engineering through standards, Harness, and Skills.

A complete AI behavior governance framework with four-layer synergy:

1. **Context Engineering** — `AGENTS.md` defines the reasoning framework, loop engineering discipline, 9-step process, coding philosophy, and security rules.
2. **Harness Layer** — 19 hook scripts upgrade key rules from "textual constraints" to "code enforcement".
3. **Skills Layer** — Reusable capability packages loaded on demand (Workflow / Debugging / Security / Architecture Review).
4. **SSoT Documentation** — `docs/STATUS.md` records context, `docs/tasks.json` tracks progress.

Cross-tool compatible: Claude Code (First-class citizen), Gemini CLI (Hooks compatible), Codex CLI (Sandbox fallback).

---

## Quick Installation

```bash
# Prerequisites
# 1. Claude Code: https://docs.claude.com/en/docs/claude-code
# 2. superpowers: https://github.com/obra/superpowers

# Execute in the project root directory
curl -sSL https://raw.githubusercontent.com/rayjun/ai-coding-context/main/install.sh | bash

# Preview files to be written (dry run)
curl -sSL .../install.sh | bash -s -- --dry-run
```

Automatic `.bak` backup before overwriting; automatic rollback on download failure.

---

## Core Specifications

### `CLAUDE.md` — Claude Code Entrypoint
Automatically loaded when Claude Code starts. References the main `AGENTS.md` specification via `@AGENTS.md` import.

### `AGENTS.md` — AI Behavior Guidelines
Reasoning framework, task complexity levels, coding philosophy, loop engineering discipline, 9-step development process, security rules, and documentation maintenance. The process is scaled via a **trivial/moderate/complex × 9-step matrix** to avoid a one-size-fits-all approach.

### `.claude/rules/` — Path-scoped Rules (Official native paths mechanism)
```yaml
---
paths:
  - ".claude/hooks/**/*.sh"
---
# Hook Development Rules
- All hook scripts must start with `set -euo pipefail`
- ...
```
Claude Code automatically injects content when editing matching files.

### `.claude/commands/` — Custom Slash Commands
- `/review` — Review current branch diff (dynamically detects base branch)
- `/status` — Project health check (`STATUS.md` freshness + tasks consistency + git status)
- `/fix-issue <n>` — Systematically fix from GitHub issue ID

> Claude Code's slash commands **do not have a `project:` prefix**. Skills take precedence in case of name collisions.

### `.claude/skills/` — On-demand Skills
5 project-level skills (workflow-management / plan-review / investigate / careful-ops / obsidian-writer) + 1 eval-runner tool. Each `SKILL.md` contains `EVAL 1..N` quality assessment blocks, which can be automatically scored using `eval-runner.py`.

> `obsidian-writer` is a **demo skill** showcasing the per-vault `AGENTS.md` rule pattern; this repo itself does not use it. Forks can drop it from `install.sh` if not needed.

### `.claude/agents/` — Subagents (Claude Code only)
Independent context windows for tasks that would otherwise pollute the main thread:

- `plan-reviewer.md` — runs the 5-dimension architectural review (data flow / concurrency / interface / testing / operability) in isolation. References `plan-review` skill as the rule SSoT, does not duplicate.
- `retro-writer.md` — extracts self-correction patterns ("expected X, actually Y") from session transcripts and appends to `docs/lessons.md`.

> Skills define rules; agents execute them. complex tasks recommend `Agent(subagent_type="plan-reviewer")`; trivial / moderate use the skill directly.

### `docs/specs/` — Spec-Driven Development (Optional)
Inspired by Kiro / spec-kit. The `requirements.md` (EARS) → `design.md` → `tasks.md` triplet is an **optional alternative** to `docs/plans/` for cross-PR / multi-week features. AGENTS.md §6 is unchanged. See `docs/specs/README.md` for when to use spec vs plan.

---

## Harness Layer (19 Hooks)

| Event | Script | Function |
|------|------|------|
| SessionStart | `orient-session.sh` | Inject git log / `STATUS.md` / tasks summary |
| UserPromptSubmit | `prompt-context.sh` | Inject tasks briefing before each conversation (with mtime caching) |
| PreToolUse Bash | `careful-ops-check.sh` | Block dangerous commands (`hookSpecificOutput` format) |
| PreToolUse Bash | `pre-commit-check.sh` | Prohibit commit if no test evidence or passive source code changes |
| PostToolUse Bash | `record-test-evidence.sh` | Record only when test/build output appears successful |
| PostToolUse Edit\|Write | `post-edit-dispatch.sh` | Merge and dispatch `status-reminder` / `format-check` / `tasks-validate` |
| PostToolUse Edit\|Write | `credential-sniff.sh` | Scan for AKIA / sk- / ghp_ / PEM / JWT |
| PostToolUse Edit\|Write | `large-file-warn.sh` | Remind to split files > 1500 lines |
| PostToolUse Edit\|Write | `migration-safety.sh` | Detect NOT NULL without default / DROP / non-CONCURRENTLY |
| PreCompact | `pre-compact.sh` | Preserve current target / plan / resume point before compaction |
| Notification | `notify.sh` | macOS / Linux desktop notifications |
| Stop | `session-end.sh` | Session end check for `STATUS` / tasks / uncommitted changes |
| Stop | `assertion-audit.sh` | Scan for "test passed" assertions and compare with evidence files |

Shared Libraries: `lib/json-extract.sh`, `lib/session-dir.sh`, `lib/task-summary.py`, `lib/danger-patterns.sh` (+ 25 unit tests), `lib/pretool-response.sh`.

### Official Compliance
- PreToolUse deny uses **`hookSpecificOutput.permissionDecision`** (not the deprecated `{decision:"deny"}` + exit 2)
- PostToolUse Bash's JSON schema lacks `exit_code`; uses `tool_response.{stdout,stderr,interrupted}` heuristic determination
- `.claude/rules/*.md`'s `paths` frontmatter is the official native loading mechanism

---

## Workflow: 9-Step Process (Scaled by Complexity)

| Step | trivial | moderate | complex |
|------|:-:|:-:|:-:|
| 1. Brainstorming | ➖ | ◯ | ✅ |
| 2. Planning + Review | ➖ | ✅ | ✅ |
| 3. Git worktree | ➖ | ➖ | ◯ |
| 4. TDD (Production Logic) | ➖ | ✅ | ✅ |
| 5. Execution (Parallel agents) | Direct | ✅ | ✅ |
| 6. Code Review | ➖ | ✅ | ✅ |
| 7. **Verification (Evidence > Assertions)** | ✅ | ✅ | ✅ |
| 8. Documentation Maintenance | ➖ | ✅ | ✅ |
| 9. Finishing Branch | ➖ | ◯ | ✅ |

✅ Required · ◯ Optional · ➖ Skippable

See `AGENTS.md` §2 §6 for details.

---

## Related Dependencies

- **Harness Philosophy**: [12 Factor Agents](https://github.com/humanlayer/12-factor-agents)
- **Skills Framework**: [superpowers](https://github.com/obra/superpowers)
- **Spec Origin**: `AGENTS.md` adapted from [Xuanwo's AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed)
- **Official Docs**: [Claude Code Hooks](https://code.claude.com/docs/en/hooks) · [Skills](https://code.claude.com/docs/en/skills) · [Memory](https://code.claude.com/docs/en/memory)
