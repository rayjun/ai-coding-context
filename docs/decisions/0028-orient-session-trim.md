# 决策 #28 · orient-session 改用 awk 截取 STATUS.md 关键段

**日期**: 2026-05-15
**状态**: Adopted

## 背景

`orient-session.sh` 在 SessionStart 阶段把 **整个 STATUS.md** 注入主线程上下文。
随着项目成熟（4 个 Round 历史段 + 6 行决策索引 + 最新发现），STATUS.md 已 ~1250 tokens。
但其中真正每次会话都需要的只有「当前目标」+「下次从这里开始」两段（约 300 tokens），其余 950 tokens 是历史和索引，每次开会话都重复注入纯属浪费。

实测瘦身前 SessionStart 注入约 6002 字节 / 1587 tokens。

## 决策

orient-session.sh 第 3 步改为用 awk 只提取以下 section：
- `## 当前目标`
- `## 下次从这里开始`

止于下一个 `## ` 标题或 `---` 分隔线。

附带提示：「(full STATUS.md including 历史/决策记录/最新发现 is on disk — Read on demand.)」

section 缺失校验**仍走全文 grep**（确保 `## 任务进度` 等必要 section 存在），不受截取影响。

## 影响

收益：
- SessionStart 注入从 6002 字节 / ~1587 tokens 降到 2454 字节 / ~818 tokens
- **节省 ~1180 tokens / session**（约 18% 主线程常驻开销）
- 历史段 / 决策索引 / 最新发现仍在 STATUS.md 文件中，LLM 可按需 Read（已有提示）

代价：
- LLM 不再开局看到全部历史段，理论上可能漏过某些上下文。**缓解**：注入文末显式提示文件位置；STATUS.md 的写作规范本来就要求历史段是「可查不必读」的。
- 校验逻辑分裂：注入用 awk 截取，缺失检测用全文 grep —— 但两者职责不同，不耦合。

后续：
- AGENTS.md §0 去 Ray 化（再省 ~150 tokens）
- tasks.json 归档机制（防 Round 8+ 膨胀）
- STATUS.md 历史段保留 N=2 Round 后切到 `STATUS.archive.md`
