---
paths:
  - ".claude/skills/**/*.md"
---

# Skill 开发规则

> 本文件由 Claude Code 的 `.claude/rules/` 原生机制加载。

- 每个 skill 在独立子目录下，主文件为 `SKILL.md`。
- Frontmatter 只允许 `name` 和 `description` 两个字段。
- `name` 保持英文标识符（工具兼容性），`description` 和正文使用简体中文。
- `description` 以触发条件开头（"...时使用"），不描述 skill 做什么。
- 每个 skill **必须**包含"质量评估标准" section，使用二元 pass/fail 的 EVAL 1..N 格式（参考 investigate / plan-review）。可用 `.claude/skills/lib/eval-runner.py` 验证 EVAL 解析是否有效。
- Skill 内容使用简体中文，代码示例使用 English。
- 新增 skill 后必须同步更新 `install.sh` 的 DIRECTORIES 和 CORE_FILES 清单。

- 每个 skill 在独立子目录下，主文件为 `SKILL.md`。
- Frontmatter 只允许 `name` 和 `description` 两个字段。
- `description` 以触发条件开头（"...时使用"），不描述 skill 做什么。
- 每个 skill 应包含"质量评估标准" section，使用 autoresearch 兼容的二元 eval 格式。
- Skill 内容使用简体中文，代码示例使用 English。
