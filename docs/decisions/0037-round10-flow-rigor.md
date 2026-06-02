# 0037 · Round 10 P0 — 流程强制度提升

**日期**: 2026-06-02
**状态**: accepted
**相关**: AGENTS.md §6, plan-reviewer agent (R4 P0 引入), tasks.json schema

## 背景

§6 流程的两条 P2 待办：
1. plan-reviewer 接入第 2 续步「强制触发」（来自 R4 后续）。
2. tasks.json 加 `spec_id` 字段（来自 R4 后续）。

R4 P0 引入 plan-reviewer agent 后 33+ 天 0 触发——本仓库 complex 任务也直接在主上下文用 plan-review skill 解决。文档措辞是「推荐」，没有 runtime 提示，等于隐形。tasks.json 没有 spec_id，task 与 plan 之间靠人脑映射。

## 决策

**A · plan-reviewer 走"软提醒"，不上拦截门禁。**

复用 `post-edit-dispatch.sh` dispatcher 加第 4 分支，匹配 `docs/plans/*.md` 编辑时输出一行 reminder。零额外 fork-exec、零阻断。

不上 commit 门禁（候选方案）的理由：
- 本仓库 trivial / moderate 任务也写 plan，但不一定需要 plan-reviewer（用 plan-review skill 即可）。commit 门禁会误伤。
- 软提醒 = 让 agent 看见，让用户决策，不剥夺判断空间。

**B · `spec_id` 走"可选 + 提醒"，不强制回填。**

schema：每个 task 可选 `spec_id`（字符串，约定 `docs/plans/<file>.md`）。
校验：字段存在时检查类型 / 路径前缀 / 文件存在；缺失静默。

不强制（候选方案）的理由：
- 18 个历史 task 跨多轮，部分已完成，回填成本高、价值低。
- trivial 任务可能没有 plan 文件，强制 = 鼓励造空 plan。

**约定 spec_id = `docs/plans/*.md`（不是 `docs/specs/*`）**：
- 决策 #0027 已把 `docs/specs/` 标为可选，本仓库未采用。
- 第 2 步 writing-plans 已经必出 plan 文件，spec_id 直接指 plan 路径，零新资产。

## 后果

**正面**：
- plan 文件写完即获 reminder，第 2 续步从「文档约定」进入 runtime。
- task ↔ plan 可追溯，回看历史进度更快。
- 零新顶层 hook 注册（接到现有 dispatcher），不增加 fork-exec。

**负面 / 取舍**：
- 软提醒可被忽略——这是有意为之，强制成本 > 收益。
- spec_id 可选 = 字段填充率会参差，但符合"trivial 不必有 plan"的现实。
- spec_id 路径前缀写死 `docs/plans/`——fork 用户若用 `docs/specs/` 需改 hook（warning 而非 error 已留弹性）。
- 多 harness 同步成本：新 hook 必须同时更新 `install.sh` CORE_FILES + `.gemini/settings.json`（按 `.claude/rules/hooks-dev.md` 规则），本轮已落地。

## 不做

- 不引入 commit 门禁拦截 plan-reviewer。
- 不强制回填历史 task 的 spec_id。
- 不引入 `docs/specs/<id>` 路径，与 #0027 保持一致。
