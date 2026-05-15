# 决策 #29 · AGENTS.md §0 去 Ray 化

**日期**: 2026-05-15
**状态**: Adopted

## 背景

`AGENTS.md` §0「关于用户与你的角色」原本写 `你正在协助的对象是 Ray`，并以 `Ray` 为主语描述偏好。
本项目作为公开模板（`rayjun/ai-coding-context`），fork 用户继承到这段后会得到一个不属于他们的姓名锚点；这与 Round 3 review P1 项「§0 去 Ray 化」对齐。

§1 还有一句"除非我要求展示"，第一人称视角与 §0 不一致。

## 决策

§0 改写为通用画像：
- 主语 `Ray` → `资深工程师` / `用户`
- 顶部加一行说明：「默认画像。如需个性化，fork 后修改本节即可，其余章节与之解耦。」
- 保留语言栈示例（Rust/Go/Java/Python/Solidity）作为典型——这是经验型工程师的常见技术面，不属于 Ray 个人特征
- 保留「Slow is Fast」「推理质量优先」等价值偏好，作为本项目对 AI 编码助手的默认导向

§1 行 14 「除非我要求展示」→「除非用户要求展示」，统一第三人称叙述。

install.sh / README.md 中 `rayjun/ai-coding-context` 是 GitHub repo URL（项目身份），**不在本次范围内**，保留。

## 影响

收益：
- §0 成为可独立替换的画像段，下游 fork 者只需改这一节即可定制
- 全文叙述视角统一（第三人称指代用户）
- 字符数仅增 ~45（fork 提示行）

代价：
- 极小。无功能影响，无 hook 改动。
- 个性化用户（保留 Ray 名字）需要在 fork 后改回 §0，但这本就是 fork 模板的预期工作流。

后续：
- §0 是否应进一步抽象到 `.claude/profiles/<name>.md` 由 install.sh 选装：当前不做，等多人反馈后评估
- README / install.sh URL 中的 `rayjun` 是 GitHub 用户名，属于项目坐标，不参与去除
