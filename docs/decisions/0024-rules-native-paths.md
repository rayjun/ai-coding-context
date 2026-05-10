# 决策 #24 · 回归 rules/*.md 原生 paths 机制

**日期**: 2026-04-27
**状态**: Adopted

## 背景

官方文档 [memory#organize-rules-with-claude/rules/](https://code.claude.com/docs/en/memory) 证实 `.claude/rules/*.md` + `paths: [...]` frontmatter 是原生加载机制。

Round 1 我错误地"改造"成子目录 CLAUDE.md 级联，属于重复造轮子。

## 决策

- 删除 `.claude/hooks/CLAUDE.md`、`.claude/skills/CLAUDE.md`、`docs/CLAUDE.md` 三个冗余文件
- `rules/*.md` 保留为 SSoT，由 Claude Code 原生按 paths glob 加载

## 影响

- 配置更精简
- 消除 SSoT 分叉
- 新人不用理解"两套路径作用域机制"
