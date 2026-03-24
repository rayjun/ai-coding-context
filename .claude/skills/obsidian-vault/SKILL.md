---
name: obsidian-vault
description: 将交互过程中的知识、上下文内容或 Markdown 文件整理到 Obsidian vault 中时使用。触发条件：用户要求整理笔记、归档内容到 vault、创建 Obsidian 笔记，或提到 vault 路径。
---

# Obsidian Vault 笔记整理

## 概览

将 AI 会话中产生的知识、决策、架构设计等内容，结构化整理到 Obsidian vault 中。核心原则：**标签即目录、目录即标签，笔记之间通过 `[[]]` 链接形成知识网络。**

## 何时使用

- 用户要求把交互内容、特定文件整理到 vault
- 会话产生了值得沉淀的架构决策、实现记录、经验总结
- 用户提到 vault 路径或 Obsidian 相关操作

## 执行协议

### 第一步：扫描 vault 惯例

每次操作前**必须**先读取 vault 现有结构，不可假设：

```bash
# 1. 目录结构
find <VAULT_PATH> -type d -not -path "*/.obsidian/*" | sort

# 2. 现有文件的标签惯例（取 5-10 个样本）
find <VAULT_PATH> -name "*.md" -type f -exec head -8 {} \; | grep -A6 "^tags:"

# 3. 文件命名模式
find <VAULT_PATH> -name "*.md" -type f | head -15
```

### 第二步：确定目标目录和标签

规则（**不可违反**）：

1. **标签 = 目录路径的小写映射**
   - `Projects/ai-coding-context/` → `projects/ai-coding-context`
   - `Engineering/Architecture/` → `engineering/architecture`
   - `Security/Incident-Analysis/` → `security/incident-analysis`

2. **标签层数不超过目录层数**
   - 文件在 `Projects/ai-coding-context/`（2 层）→ 标签最多 2 段：`projects/ai-coding-context`
   - 不可出现 `projects/ai-coding-context/hooks` 除非该子目录真实存在

3. **每个笔记的标签组成**
   - 第一个标签：文件所在目录的路径标签（必填）
   - 后续标签：内容相关的已有目录标签（可选，从 vault 现有目录中选取）
   - 特殊标签：`MOC` 用于索引页

4. **不发明新标签**——只使用与已有目录匹配的标签。如果需要新分类，先创建目录。

### 第三步：写入笔记

文件名格式：`YYYY.MM.DD-xxxx.md`

其中 `xxxx` 是**内容的英文短描述**（kebab-case），例如：
- `2026.03.23-harness-architecture.md`
- `2025.11.03-balancer-v2-rounding-exploit.md`

Frontmatter 格式：

```yaml
---
tags:
  - <目录路径标签>
  - <内容分类标签>（可选）
created: YYYY-MM-DD
---
```

### 第四步：建立链接

1. **同项目内的笔记**：用 `[[文件名不含.md]]` 互相链接
2. **跨目录的相关笔记**：在"相关笔记"section 中用 `[[]]` 链接
3. **索引页（MOC）**：项目目录下创建 `YYYY.MM.DD-xxx-index.md`，汇总所有笔记的 `[[]]` 链接
4. **反向链接**：新笔记引用了已有笔记时，在已有笔记的"相关笔记"section 中追加反向链接

### 第五步：验证

```bash
# 1. 标签与目录匹配
for f in <目标目录>/*.md; do
  grep -A5 "^tags:" "$f" | grep "  -"
done

# 2. 所有 [[]] 链接的目标文件存在
grep -r '\[\[' <目标目录>/ | grep -o '\[\[[^]]*\]\]' | sort -u

# 3. 无孤立笔记（每个笔记至少被一个其他笔记链接）
```

## 笔记内容模板

### 架构/概念类

```markdown
# 标题

## 概览
一两句话核心原理。

## 详细内容
（表格、代码块、对比等）

## 相关笔记
- [[相关笔记1]] — 一句话说明关系
- [[相关笔记2]] — 一句话说明关系
```

### 实现记录类

```markdown
# 标题

## 背景
为什么要做这件事。

## 过程
关键步骤和决策。

## 经验总结
1. 要点一
2. 要点二

## 相关笔记
```

### 索引页（MOC）

```markdown
# 项目名索引

一段项目简介。

## 笔记索引

### 分类一
- [[笔记1]] — 简述
- [[笔记2]] — 简述

### 分类二
- [[笔记3]] — 简述

## 项目状态
当前状态摘要。
```

## 常见错误

| 错误 | 正确做法 |
|------|---------|
| 标签使用 `project/xxx`（单数） | 看 vault 中的实际惯例，如 `projects/xxx`（复数） |
| 发明 vault 中不存在的标签 | 只用与已有目录匹配的标签 |
| 标签层数超过目录层数 | `Projects/foo/` 最多 `projects/foo`，不可 `projects/foo/bar` |
| 笔记之间没有 `[[]]` 链接 | 每个笔记至少链接到索引页 + 1 个相关笔记 |
| 没有先扫描 vault 就开始写 | 必须先执行第一步，了解命名和标签惯例 |

## 质量评估标准

以下为二元（pass/fail）评估项，用于验证本 skill 输出质量。可配合 autoresearch 工具自动化运行。

```
EVAL 1: 标签-目录匹配
问题: 笔记中每个标签是否都能在 vault 目录树中找到对应路径？
Pass: 所有标签均可映射到 vault 中已存在的目录（小写化后完全匹配）
Fail: 出现任何一个标签在 vault 目录树中无对应路径

EVAL 2: 标签层数
问题: 笔记中每个标签的层数（/分隔段数）是否 ≤ 文件所在目录的深度？
Pass: 所有标签的段数不超过文件相对于 vault 根的目录层数
Fail: 出现任何一个标签的段数超过目录层数

EVAL 3: 文件名格式
问题: 文件名是否遵循 YYYY.MM.DD-xxxx.md 格式，且 xxxx 为英文 kebab-case？
Pass: 日期格式正确，描述部分为全小写字母和连字符，无中文/空格/特殊字符
Fail: 日期格式错误，或描述部分包含非法字符

EVAL 4: 链接完整性
问题: 笔记中所有 [[]] 链接的目标文件是否存在于 vault 中？
Pass: 每个 [[target]] 在 vault 中都能找到对应的 target.md
Fail: 出现任何悬空链接

EVAL 5: vault 扫描前置
问题: 在写入任何笔记之前，是否执行了 vault 目录结构和标签惯例的扫描？
Pass: 工具调用记录中显示先执行了 find/ls 扫描 vault，然后才创建文件
Fail: 直接创建文件，未先扫描

EVAL 6: Frontmatter 完整
问题: 每个笔记是否包含有效的 YAML frontmatter（tags + created 字段）？
Pass: frontmatter 格式正确，tags 为数组，created 为 YYYY-MM-DD 格式
Fail: 缺少 frontmatter、tags 或 created 字段，或格式不符
```
