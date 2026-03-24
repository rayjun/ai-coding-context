---
paths:
  - ".claude/skills/**/*.md"
---

# Skill 开发规则

- 每个 skill 在独立子目录下，主文件为 `SKILL.md`。
- Frontmatter 只允许 `name` 和 `description` 两个字段。
- `description` 以触发条件开头（"...时使用"），不描述 skill 做什么。
- 每个 skill 应包含"质量评估标准" section，使用 autoresearch 兼容的二元 eval 格式。
- Skill 内容使用简体中文，代码示例使用 English。
