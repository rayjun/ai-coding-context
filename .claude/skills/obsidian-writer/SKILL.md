---
name: obsidian-writer
description: 将内容写入 Obsidian vault 时使用。与 obsidian-vault（内置规则）不同，本 skill 从 vault 根目录的 AGENTS.md 动态读取用户自定义写入规则。触发条件：用户要求把笔记写入 vault、整理到 Obsidian，或明确提到 "obsidian-writer" / "写入 vault"。
---

# Obsidian Writer

## 概览

把 AI 会话内容写入用户的 Obsidian vault。**规则源**不是本 skill 的硬编码约定，而是 **vault 根目录的 `AGENTS.md`** — 每个 vault 可以有自己的命名/标签/目录惯例，本 skill 只负责读取并遵守。

和姊妹 skill `obsidian-vault` 的区别：

| 维度 | obsidian-vault | obsidian-writer (本文件) |
|------|----------------|-------------------------|
| 规则来源 | skill 内置（目录 = 标签、小写映射等） | vault 根 `AGENTS.md`（每个 vault 自定义） |
| 路径配置 | 无；每次写入前扫 vault | 首次交互式设置，持久化 |
| fail-close | 否（缺规则用默认） | 是（缺 `AGENTS.md` 拒绝写入） |
| 适用场景 | 单 vault、规则稳定 | 多 vault / 团队 vault / 规则频繁演进 |

## 何时使用

- 用户明确要求把某段交互、文件或笔记**写入 Obsidian vault**
- 用户的 vault 拥有根目录 `AGENTS.md` 定义的自定义写入规范
- 需要尊重 vault 方的元数据（标签体系、文件命名、frontmatter 字段）规则而非 skill 内置规则

## 执行协议

### 阶段 1：定位 vault 路径

按顺序尝试，首个非空命中即用：

1. 环境变量 `OBSIDIAN_VAULT_PATH`（推荐在 `~/.claude/settings.json` 的 `env` 块中配置）
2. 文件 `~/.claude/obsidian-vault.path` 的首行

脚本统一入口：

```bash
VAULT=$(.claude/skills/obsidian-writer/scripts/resolve-vault.sh)
```

退出码 0 → `$VAULT` 是绝对路径的已存在目录。
退出码 1 → 未配置或配置失效，进入阶段 1a。

### 阶段 1a：首次交互式设置

若阶段 1 失败：

1. **不要猜测路径**，也不要默认写到某处。
2. 用 AskUserQuestion 询问 vault 的绝对路径（示例 header "Vault 路径"），解释该路径会被持久化到 `~/.claude/obsidian-vault.path`。
3. 用户回答后调用：

   ```bash
   .claude/skills/obsidian-writer/scripts/set-vault.sh "/abs/path/to/vault"
   ```

   该脚本会校验目录存在 + 根目录 `AGENTS.md` 存在后才写入配置。任何一项失败则拒绝保存。

4. 保存成功后提示用户把路径也加到 `~/.claude/settings.json` 的 `env` 块，未来会话可通过环境变量而非磁盘读取解析（更快、更明确）。

### 阶段 2：加载 vault 根目录 AGENTS.md

确认路径后，**必须**读取 `$VAULT/AGENTS.md`。若文件缺失：

- 立即停止，不要写入任何文件。
- 提示用户在 vault 根目录创建 `AGENTS.md`，并列出期望包含的章节（命名规则、标签、目录结构、frontmatter 模板）。
- **不要** fallback 到 obsidian-vault 的内置规则 — 本 skill 设计为 fail-close，规则源必须显式。

加载后，把 `AGENTS.md` 内容当作本次写入会话的**权威规则**。本 SKILL.md 的任何隐含约定（比如某种文件命名）均被 vault AGENTS.md 覆盖。

### 阶段 3：按 vault AGENTS.md 规则写入

根据 `$VAULT/AGENTS.md` 中的规则逐项执行。常见的规则类别：

- **目标目录**：文件应落在哪个子目录
- **文件命名**：日期前缀 / kebab-case / 语言等
- **Frontmatter**：必填字段（tags / created / aliases / status 等）
- **标签惯例**：命名空间、大小写、层级
- **链接策略**：`[[wikilink]]` vs `[[wikilink|显示名]]`、索引页（MOC）引用
- **去重校验**：是否要求检查已有同名文件

所有写入通过 Write 工具，路径必须以 `$VAULT/` 开头。

### 阶段 4：验证

写入后：

1. 读回文件确认内容完整
2. 检查 frontmatter YAML 合法
3. 列出新建/修改的文件绝对路径给用户确认
4. 若有反向链接（已有笔记引用新笔记），也一并更新

## 快速参考

| 步骤 | 关键动作 | 失败处理 |
|------|---------|---------|
| 1 | 调用 `resolve-vault.sh` | 失败 → 进阶段 1a |
| 1a | AskUserQuestion + `set-vault.sh` | 校验失败 → 再次询问 |
| 2 | Read `$VAULT/AGENTS.md` | 不存在 → 拒绝写入 + 提示用户创建 |
| 3 | 按 AGENTS.md 规则 Write | 违反规则 → 修正后重试 |
| 4 | 读回 + 列出路径 | 校验失败 → 回滚 / 报告问题 |

## 常见错误

| 错误 | 正确做法 |
|------|---------|
| vault 路径硬编码到脚本 | 用 `resolve-vault.sh` 按优先级解析 |
| 缺 `AGENTS.md` 时套用默认规则 | Fail-close：拒绝写入并提示 |
| 路径配置写到项目 settings.json | 应在用户全局（`~/.claude/settings.json`）或专用文件 |
| 同一会话反复 AskUserQuestion | 持久化一次，之后复用 |
| 忽略 vault AGENTS.md 的 frontmatter 字段 | 先 parse AGENTS.md，再按字段表构造 frontmatter |
| 把本 SKILL.md 的约定当规则写入 | 本 skill 只是工作流骨架，真正规则来自 vault AGENTS.md |

## 质量评估标准

以下为二元（pass/fail）评估项。

```
EVAL 1: 路径解析前置
问题: 在任何写入动作之前，是否先通过 resolve-vault.sh 获取了 vault 绝对路径？
Pass: transcript 中能看到 resolve-vault.sh 调用，且后续 Write 路径以该值为前缀
Fail: 直接猜测路径 / 硬编码 / 先写后查

EVAL 2: 首次缺路径的交互式补齐
问题: 若路径未配置，是否用 AskUserQuestion 获取并通过 set-vault.sh 持久化？
Pass: 询问轮次 + set-vault.sh 调用 + ~/.claude/obsidian-vault.path 被创建
Fail: 静默失败 / 自己给默认值 / 不持久化

EVAL 3: AGENTS.md 加载
问题: 在第一次写入前，是否 Read 了 $VAULT/AGENTS.md？
Pass: 能看到 Read 调用命中 <vault>/AGENTS.md，且后续决策引用其内容
Fail: 直接写入 / 用了本 SKILL.md 的约定 / 用 obsidian-vault 默认规则

EVAL 4: AGENTS.md 缺失的 fail-close
问题: 若 vault 根没有 AGENTS.md，是否拒绝写入并提示用户？
Pass: 明确声明不写入，列出创建指引
Fail: 套用任何默认规则继续写入

EVAL 5: 路径前缀约束
问题: 所有 Write 调用的 file_path 是否以解析得到的 $VAULT/ 绝对前缀开头？
Pass: 每次 Write 的 path 可追溯到 vault 根
Fail: 出现相对路径或 vault 外路径

EVAL 6: 写后验证
问题: 写入后是否 Read 回新文件并列出绝对路径给用户？
Pass: 看到读回动作 + 路径清单汇报
Fail: 写完直接结束 / 不报告
```
