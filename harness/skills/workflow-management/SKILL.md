---
name: workflow-management
description: 当执行非平凡的开发任务时使用，以确保从需求分析到最终文档化的标准 9 步开发流程。
---

# 工作流管理 (Workflow Management)

## 何时使用
- 实现新功能或重构代码。
- 修复 Bug 或解决架构问题。
- 任何需要正式计划和验证的开发任务。

## 流程定义

**唯一 SSoT**：`AGENTS.md` §6「强制开发流程（9 步）」+ §2「任务复杂度」分级矩阵 + §6「Loop Engineering」。

本 skill 只是触发器与质量评估器，不复述流程。如需流程内容，直接读 AGENTS.md。

## 关键纪律
- 禁止静默跳步；跳步前明确说明原因并等待用户确认。
- 计划前不写实现代码（测试除外）。
- 非 trivial 任务要先定义 loop 的观察信号、退出条件和升级条件。
- 审查/验证失败时做最小修改并重跑同一 gate，不无界自旋。
- 完成前必须出示证据（实际命令输出）。
- 步骤切换时播报「进入第 N 步：【名称】」。

## 质量评估标准

以下为二元（pass/fail）评估项，用于验证本 skill 输出质量。可配合 autoresearch 工具自动化运行。

```
EVAL 1: 步骤播报
问题: 在每个步骤切换时，是否明确播报了"进入第 N 步：【名称】"？
Pass: transcript 中能找到每一次步骤切换的播报语句
Fail: 出现未播报的静默步骤切换，或直接从 Plan 跳到 Execute 无任何提示

EVAL 2: 计划文件前置
问题: 是否在第二步产出了 docs/plans/*.md 文件，且该文件存在于实现代码之前？
Pass: docs/plans/ 下有对应计划文件，git 提交时间早于实现代码
Fail: 直接开始实现代码，或计划文件与实现代码在同一次编辑中产生

EVAL 3: 验证证据
问题: 第 7 步（验证）是否展示了测试/构建命令的实际 stdout/stderr 输出？
Pass: 能看到真实的命令输出（测试数量、pass/fail 行、时间戳）
Fail: 只写"测试通过"而无输出，或输出被总结抹除掉数字

EVAL 4: tasks.json 同步
问题: 任务状态变更（pending → in_progress → done）是否及时写入 docs/tasks.json？
Pass: 每个步骤的开始/结束都能在 tasks.json 的 diff 中看到对应 status 变更
Fail: tasks.json 不存在、长时间未更新，或状态与实际不符

EVAL 5: STATUS.md 落地
问题: 第 8 步是否更新了 docs/STATUS.md 的当前目标 / 最新发现 / 下次从这里开始？
Pass: STATUS.md 的时间戳为本次会话，且上述 3 个 section 有实质更新
Fail: STATUS.md 未动，或只更新时间戳而内容未变

EVAL 6: 跳步说明
问题: 如果跳过了任何一步，是否明确说明原因并等待用户确认？
Pass: 跳步时有明确的 "跳过第 N 步：【原因】" 声明，且有用户确认轨迹
Fail: 静默跳步，或跳步后才补说明

EVAL 7: Loop Engineering 边界
问题: 非 trivial 任务是否定义了 loop 的观察信号、下一步假设、退出条件和升级条件，并在审查/验证失败后重跑同一 gate？
Pass: transcript 或计划中能看到成功信号、下一步假设、停止/升级条件；失败后有最小修改 + 同 gate 复验
Fail: 失败后直接结束、无界反复修改，或没有说明何时停止/升级
```
