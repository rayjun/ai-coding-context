---
name: obsidian-writer
description: 将内容写入 Obsidian vault 时使用。规则源为 vault 根目录的 AGENTS.md（每个 vault 自定义命名/标签/frontmatter 惯例）。触发条件：用户要求把笔记写入 vault、整理到 Obsidian，或提到"整理到 vault / 归档到 Obsidian / 创建 Obsidian 笔记"。
---

# Obsidian Writer

## 概览

把 AI 会话中的知识、决策、架构设计、调研结果等内容写入 Obsidian vault。**规则源**是 vault 根目录的 `AGENTS.md` — 每个 vault 自定义命名、标签、目录、frontmatter 惯例，本 skill 读取并遵守。

核心原则：**标签即目录、目录即标签；笔记通过 `[[]]` 链接形成知识网络；规则来自 vault，不来自 skill**。

## 何时使用

- 用户要求把某段交互、文件或笔记**写入 Obsidian vault**
- 会话产生了值得沉淀的架构决策、实现记录、经验总结
- 用户提到 vault 路径、Obsidian 相关操作、"整理到 vault"、"归档到 Obsidian"

## 执行协议

### 阶段 1：定位 vault 路径

按优先级解析，首个命中即用：

1. 环境变量 `OBSIDIAN_VAULT_PATH`（推荐配在 `~/.claude/settings.json` 的 `env` 块）
2. 文件 `~/.claude/obsidian-vault.path`（由 `set-vault.sh` 管理）

统一入口：

```bash
VAULT=$(.claude/skills/obsidian-writer/scripts/resolve-vault.sh)
```

- exit 0 → `$VAULT` 是绝对路径的已存在目录
- exit 1 → 未配置，进入阶段 1a

### 阶段 1a：首次交互式设置

若阶段 1 失败：

1. **不要猜测路径**，也不要默认写到某处
2. 用 AskUserQuestion 询问 vault 的绝对路径（header "Vault 路径"），说明路径会持久化到 `~/.claude/obsidian-vault.path`
3. 调用：
   ```bash
   .claude/skills/obsidian-writer/scripts/set-vault.sh "/abs/path/to/vault"
   ```
   脚本三重校验：绝对路径 / 目录存在 / `<vault>/AGENTS.md` 存在；任一失败则拒绝保存
4. 建议用户把路径加到 `~/.claude/settings.json` 的 `env.OBSIDIAN_VAULT_PATH`，未来通过 env 解析（更快、更明确）

### 阶段 2：加载 vault 根目录 AGENTS.md（强制）

确认路径后**必须** Read `$VAULT/AGENTS.md`。若文件缺失：

- **立即停止**，不写入任何文件
- 提示用户在 vault 根创建 `AGENTS.md`，引导参考"vault AGENTS.md 推荐结构"（本文档附录）
- **不要**套用任何默认规则 — 本 skill 设计为 fail-close，规则源必须显式

加载后，`AGENTS.md` 的内容即本次会话的**权威规则**。本 SKILL.md 的任何说明若与之冲突，以 vault AGENTS.md 为准。

### 阶段 3：扫 vault 现状（按 AGENTS.md 指引）

若 vault AGENTS.md 指示"写入前需扫描现有结构"，执行：

```bash
# 目录结构
find "$VAULT" -type d -not -path "*/.obsidian/*" | sort

# 现有 frontmatter 样本（取 5-10 个）
find "$VAULT" -name "*.md" -type f -exec head -8 {} \;

# 文件命名样本
find "$VAULT" -name "*.md" -type f | head -15
```

扫描结果用于对照 AGENTS.md 中的规则，确认命名 / 标签 / 目录是否与实际一致。发现规则与现实分叉时，**优先相信 AGENTS.md**（告知用户冲突，建议同步）。

### 阶段 4：按 AGENTS.md 规则写入

常见规则类别（由 vault AGENTS.md 提供具体约束）：

- **目标目录**：文件应落在哪个子目录
- **文件命名**：日期前缀 / kebab-case / 语言 / 主题
- **Frontmatter**：必填字段（tags / created / aliases / status / source 等）
- **标签**：命名空间、大小写、层级、是否允许自创
- **链接**：`[[wikilink]]` 策略、索引页（MOC）引用、反向链接
- **去重**：同名检查、aliases 冲突

所有写入通过 Write 工具，路径必须以 `$VAULT/` 开头。

### 阶段 5：写后验证

1. Read 回新文件，确认内容完整
2. 校验 frontmatter YAML 合法（`python3 -c "import yaml; yaml.safe_load(...)"` 或手 parse）
3. 检查所有 `[[]]` 链接目标在 vault 中真实存在（无悬空链接）
4. 若 AGENTS.md 要求反向链接，更新被引用的已有笔记
5. 列出新建/修改文件的绝对路径给用户确认

## 快速参考

| 阶段 | 关键动作 | 失败处理 |
|------|---------|---------|
| 1 | `resolve-vault.sh` | exit 1 → 进阶段 1a |
| 1a | AskUserQuestion → `set-vault.sh` | 校验失败 → 再问 |
| 2 | Read `$VAULT/AGENTS.md` | 不存在 → 拒绝写入 + 引导创建 |
| 3 | 扫 vault 对齐规则 | 规则与现实冲突 → 以 AGENTS.md 为准并告知 |
| 4 | 按 AGENTS.md 规则 Write | 违反 → 修正后重试 |
| 5 | Read 回 + 校验 + 报告 | 校验失败 → 回滚并报告 |

## 常见错误

| 错误 | 正确做法 |
|------|---------|
| vault 路径硬编码 | 用 `resolve-vault.sh` 按优先级解析 |
| 缺 `AGENTS.md` 时套默认规则 | Fail-close：拒绝并引导创建 |
| 路径配置写进项目 settings.json | 应在用户全局或专用 `~/.claude/obsidian-vault.path` |
| 同一会话反复 AskUserQuestion | 持久化一次，之后复用 env / 文件 |
| 标签使用 `project/xxx`（单数） | 看 vault AGENTS.md + 现有目录惯例 |
| 发明 vault 中不存在的标签 | 只用 AGENTS.md 列出的或现有目录映射 |
| 标签层数超过目录层数 | 标签段数 ≤ 目录深度 |
| 笔记之间无 `[[]]` 链接 | 至少 1 条相关笔记 + 1 条索引页链接 |
| 没扫 vault 就写 | 阶段 3 先扫现状对齐规则 |
| 把本 SKILL.md 约定当规则 | 本 skill 是骨架，规则来自 vault AGENTS.md |

---

## 附录 A：vault AGENTS.md 推荐结构

用户第一次创建 `<vault>/AGENTS.md` 时可以参考以下模板。**本模板不是规则本身**，只是常见字段清单 —— 用户根据自己 vault 的实际惯例裁剪、改写。

```markdown
# Vault Writing Rules

## 目录结构
- Projects/<project-name>/ — 项目笔记
- Engineering/Architecture/ — 架构文档
- Security/Incident-Analysis/ — 安全事件
- Knowledge/ — 通用知识

## 标签规则
1. 标签 = 目录路径的小写映射
   - `Projects/foo/` → `projects/foo`
   - `Engineering/Architecture/` → `engineering/architecture`
2. 标签段数 ≤ 目录深度
3. 第一个标签 = 文件所在目录路径标签（必填）
4. 不发明新标签；需新分类先建目录
5. 特殊标签：`MOC` 用于索引页

## 文件命名
- 格式：`YYYY.MM.DD-<kebab-case-英文描述>.md`
- 示例：`2026.04.27-harness-architecture.md`

## Frontmatter
```yaml
---
tags:
  - <目录路径标签>
  - <内容分类标签>（可选）
created: YYYY-MM-DD
aliases: []   # 可选
source: ""    # 可选，记录来源 URL
---
```

## 链接策略
- 同项目内笔记：`[[文件名不含.md]]`
- 跨目录相关笔记：在"相关笔记" section 列出
- 索引页（MOC）：项目目录下创建 `YYYY.MM.DD-<project>-index.md`
- 反向链接：新笔记引用已有笔记时，在已有笔记的"相关笔记"section 追加

## 笔记内容模板

### 架构 / 概念类
\`\`\`markdown
# 标题

## 概览
一两句核心原理。

## 详细内容
（表格、代码块、对比）

## 相关笔记
- [[笔记 1]] — 一句说明关系
- [[笔记 2]] — 一句说明关系
\`\`\`

### 实现记录类
\`\`\`markdown
# 标题

## 背景
为什么做这件事。

## 过程
关键步骤与决策。

## 经验总结
1. 要点一
2. 要点二

## 相关笔记
\`\`\`

### 索引页（MOC）
\`\`\`markdown
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
\`\`\`

## 去重与冲突
- 写前检查同名文件（`find <VAULT> -name "YYYY.MM.DD-slug.md"`）
- 命中则追加 `-v2` 或换 slug，不覆盖

## 验证清单
- [ ] 标签都能在目录树中找到对应路径
- [ ] `[[]]` 链接目标存在
- [ ] 新笔记至少 1 条相关链接 + 1 条索引页链接
```

## 质量评估标准

以下为二元（pass/fail）评估项。可配合 `.claude/skills/lib/eval-runner.py` 自动化。

```
EVAL 1: 路径解析前置
问题: 在任何写入动作之前，是否先通过 resolve-vault.sh 获取 vault 绝对路径？
Pass: transcript 中看到 resolve-vault.sh 调用，且后续 Write 路径以该值为前缀
Fail: 直接猜测路径 / 硬编码 / 先写后查

EVAL 2: 首次缺路径的交互式补齐
问题: 若路径未配置，是否用 AskUserQuestion 获取并通过 set-vault.sh 持久化？
Pass: 询问轮次 + set-vault.sh 调用 + ~/.claude/obsidian-vault.path 被创建
Fail: 静默失败 / 自给默认值 / 不持久化

EVAL 3: AGENTS.md 加载
问题: 在第一次写入前，是否 Read 了 $VAULT/AGENTS.md？
Pass: 能看到 Read 调用命中 <vault>/AGENTS.md，且后续决策引用其内容
Fail: 直接写入 / 用本 SKILL.md 约定 / 用硬编码规则

EVAL 4: AGENTS.md 缺失的 fail-close
问题: 若 vault 根没有 AGENTS.md，是否拒绝写入并提示用户？
Pass: 明确声明不写入，给出创建指引（可引用附录 A）
Fail: 套用任何默认规则继续写入

EVAL 5: 路径前缀约束
问题: 所有 Write 调用的 file_path 是否以解析得到的 $VAULT/ 绝对前缀开头？
Pass: 每次 Write 路径可追溯到 vault 根
Fail: 出现相对路径或 vault 外路径

EVAL 6: 标签-目录匹配（若 vault AGENTS.md 采用"目录即标签"规则）
问题: 笔记中每个标签是否能在 vault 目录树中找到对应路径？
Pass: 所有标签均可映射到 vault 中已存在的目录（小写化后完全匹配）
Fail: 出现任何标签在 vault 目录树中无对应路径

EVAL 7: 链接完整性
问题: 笔记中所有 [[]] 链接的目标文件是否存在于 vault 中？
Pass: 每个 [[target]] 在 vault 中找到对应 target.md（或 target 作为 alias）
Fail: 出现任何悬空链接

EVAL 8: 写后验证
问题: 写入后是否 Read 回新文件并列出绝对路径给用户？
Pass: 看到读回动作 + 路径清单汇报
Fail: 写完直接结束 / 不报告
```
