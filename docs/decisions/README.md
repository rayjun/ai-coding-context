# 决策记录索引

每个决策一个文件，命名 `NNNN-kebab-slug.md`。模板：

```markdown
# 决策 #NN · 标题

**日期**: YYYY-MM-DD
**状态**: Adopted | Superseded by #XX | Deprecated

## 背景
为什么需要这个决策。

## 决策
具体做了什么。

## 影响
后果、收益、代价。
```

## 已归档

| # | 标题 | 日期 |
|---|------|------|
| 22 | [record-test-evidence 改用 stdout 启发式](./0022-record-evidence-heuristic.md) | 2026-04-27 |
| 23 | [PreToolUse deny 格式全面升级](./0023-pretool-deny-format.md) | 2026-04-27 |
| 24 | [回归 rules/*.md 原生 paths 机制](./0024-rules-native-paths.md) | 2026-04-27 |
| 25 | [纠正斜杠命令语法文档](./0025-slash-command-syntax.md) | 2026-04-27 |

> #1-#21 散落在历史 STATUS.md 与 commit log；2026-05-10 起新决策外置到本目录。
