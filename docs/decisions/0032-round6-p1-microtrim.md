# 决策 #32 · Round 6 P1 Context 三轮微调

**日期**: 2026-05-24
**状态**: Adopted

## 背景

Round 6 P0 落地后剩下 3 项 P1 + 1 项 Round 5 遗漏：

1. AGENTS.md §6 流程规则 6 条里 #1 「禁止静默跳步」与 #6 「流程违反提醒」语义重复。
2. obsidian-writer skill 在本项目从未被触发，定位介于「死 skill」（应删，参考 monitoring-security）与「示例 skill」（保留作设计模式演示）之间。
3. AGENTS.md §9「其他约定」只剩 3 句话，主题（输出风格）与 §4「语言与风格」一致。
4. Round 5 删 monitoring-security 后 README 仍写「6 project-level skills」，未同步。

## 决策

### #1 — §6 流程规则合并 6 → 5

把 #6「流程违反提醒 — 提醒用户将跳过哪些步骤」并入 #1「禁止静默跳步」：

> 1. **禁止静默跳步** — 跳步前需说明原因、列出将跳过哪些步骤，并等待用户确认。

### #2 — §9 整段合并到 §4，新增 ### 输出风格 子段

§4 内部结构调整：核心输出风格规则（默认不讲基础语法、优先讲架构、回答四段式）从独立的 §9 移入 §4 作为子小节。AGENTS.md 章节从 0-9 缩为 0-8。

### #3 — obsidian-writer 标记为示例 skill

SKILL.md frontmatter 之后加一段 blockquote：

> **示例 skill**：本 skill 演示「per-vault AGENTS.md 驱动规则」的设计模式，本仓库自身不使用。fork 后如不需要可直接删除（同时从 install.sh 的 DIRECTORIES + CORE_FILES 移除对应行）。

不动 frontmatter（保持 Claude Code 触发器接口稳定）。

### #4 — README 同步 5 个核心 skill

```
5 project-level skills (workflow-management / plan-review / investigate / careful-ops / obsidian-writer) + 1 eval-runner tool.
> obsidian-writer is a demo skill ... forks can drop it ...
```

修复 Round 5 删 monitoring-security 后的数字 drift。

## 影响

实测：
- AGENTS.md：5246 → 5092 chars（**-50 tokens**）
- orient-session 输出：2330 → 2226 bytes（**-35 tokens**，部分来自 STATUS.md 当前段更紧凑）
- 累计 Round 6（P0 + P1）节省 ~205 tokens / SessionStart

正确性收益：
- §6 流程规则不再有语义重复条目
- AGENTS.md 章节 0-8 连续，无残留 §9 小段
- obsidian-writer 定位明确为示例，避免 fork 用户误以为是项目核心
- README 数字与实际 skill 数一致

代价：
- AGENTS.md §9 章节号变化（0-9 → 0-8）。**缓解**：决策 #31 / #29 等历史引用都是 §0/§3/§4 等具体编号，未引用 §9，无需修复。

## 验证

- §6 流程规则条数 = 5
- §9 grep = 0
- §4 含 `### 输出风格`
- obsidian-writer SKILL 含「示例 skill」
- README 含「5 project-level skills」+「demo skill」
- AGENTS.md 总章节数 9（§0-§8）
- danger-patterns 25/25 PASS

## 后续

- Round 7：是否考虑把 AGENTS.md §6 外置成 process.md（目前 §6 占 ~2127 chars / ~700 tokens，是单章节最大）
- tasks.json 归档机制（防 Round 8+ 膨胀）
