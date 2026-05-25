# 决策 #33 · Round 7 P0 跨 surface 去重

**日期**: 2026-05-25
**状态**: Adopted

## 背景

Round 6 P0/P1 落地后，做第三轮 context audit 发现「跨文件重复声明同一规则」是当前最大的细节债：

- 「禁止静默跳步」在 AGENTS.md / CLAUDE.md / workflow-management skill 共 5 处声明
- 「证据先于断言」在 AGENTS.md / 2 个 hook 共 6 处声明
- §6 表头 superpowers 注解把 8 个 skill 名又列一遍（与表格 Skill 列重复）
- §8「Harness 提醒」3 行 bullet 与 hook 文件首注释完全重复

## 决策

### #1 — §6 表头 superpowers 注解去重 + 表格加 ★

注解从 8 个 skill 名展开 → 短句「★ 标的来自 superpowers」；表格 Skill 列对外部 skill 加 `★` 后缀。

### #2 — §6 表头删除「跳步前必须明确询问用户确认，**禁止静默跳过**」

§6 流程规则 #1 已经是 SSoT，表头那行是重复声明。

### #3 — §2 矩阵脚注「必做 = 禁止静默跳过，跳须询问用户」改为「必做 = 必须执行（跳步规则见 §6）」

把跳步规则的描述权下沉到 §6 流程规则 #1，避免 §2 §6 各说一遍。

### #4 — §8 删除「Harness 提醒」3 行 bullet

`status-reminder.sh` / `drift-detector.sh` / `session-end.sh` 三个 hook 自身首注释已说明职责；要看完整 hook 注册可读 `.claude/settings.json`。AGENTS.md 这 3 行 bullet 不增信息。

### 不做的事
- CLAUDE.md / workflow-management skill 的「禁止静默跳步」表述保留 —— 它们各自承担入口提醒和触发器作用，不算冗余。
- 「证据先于断言」hook 文案不抽 lib/messages.sh —— 提前抽象算过度工程，等本地化需求出现再做。
- STATUS.md section 名硬编码不抽 status-sections.sh —— 同上。

## 影响

实测：
- AGENTS.md：5092 → 4708 chars（**-128 tokens**）
- orient-session 输出：2226 → 2202 bytes（**-8 tokens**）
- 「禁止静默」AGENTS.md 内部从 3 处降到 1 处（§6 流程规则 #1 唯一 SSoT）

正确性收益：
- §6 表格 ★ 后缀让「外部 skill vs 仓库自有 skill」一眼可辨
- §2 矩阵脚注不再与 §6 流程规则同主题，关注点解耦
- §8 不再重复 hook 文件首注释

## 验证

- 「禁止静默」AGENTS.md 内 grep = 1（§6 流程规则 #1）
- §6 表头 ★ 注解 = 1
- §6 表格 superpowers skill 加 ★ = 8
- §8 「Harness 提醒」grep = 0
- danger-patterns 25/25 PASS

## 后续

- Round 7 P1（可选）：CLAUDE.md / workflow-management skill 的「禁止静默跳步」是否也去（评估实际收益）
- Round 7 P2：若 STATUS.md section 名再被引用第 4 次，抽 status-sections.sh
- Round 8：tasks.json 归档机制
