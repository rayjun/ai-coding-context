> **最后更新**: 2026-03-11 10:30 UTC
> **当前阶段**: [Skill 规范化重写 - Claude 格式]
> **整体进度**: 0/2 任务完成 (0%)

## 当前目标
按照 Claude Skills 官方规范重构所有 SKILL.md 文件，包含 YAML 前置元数据（name, description），并确保描述以 "Use when..." 开头，不包含 emoji。
**参考**: [writing-skills](activated_skill)

## 任务进度 (0/2)

### 进行中
#### Task-30: 重写 workflow-management 和 monitoring-security Skill
**状态**: 正在按照 YAML frontmatter 格式拟定文案。
**下一步**: 实施文件修改。

### 待办
#### Task-31: 验证 Skill 是否能被正确加载并遵循

## 最新发现
- 规范要求描述字段必须描述“何时使用”，而不是“做了什么”。
- 禁止在 frontmatter 中使用特殊字符或 emoji。

## 决策记录
### 决策 #16: 严格遵循 Claude Skill 格式
**背景**: 提升 Skill 的可搜索性和执行确定性。
**决策**: 采用标准的 YAML + Markdown 结构，移除所有非标准标题。

## 下次从这里开始
### 继续工作
"按照新规范重构两个 Skill 文件"
