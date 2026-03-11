> **最后更新**: 2026-03-11 10:45 UTC
> **当前阶段**: [Skill 国际化 - 中文翻译]
> **整体进度**: 0/2 任务完成 (0%)

## 当前目标
将 skills 目录下的所有 SKILL.md 文件翻译为中文，同时保持 Claude Skill 的 YAML 前置元数据规范和无 emoji 的结构。
**参考**: [writing-skills](activated_skill)

## 任务进度 (0/2)

### 进行中
#### Task-32: 翻译 workflow-management 和 monitoring-security Skill
**状态**: 正在准备中文文案。
**下一步**: 实施文件修改。

### 待办
#### Task-33: 文档补全与 GitHub 同步

## 最新发现
- 翻译时需保留 YAML 中的 `name` 为英文标识符，以确保工具兼容性。
- `description` 需翻译为以“当...时使用”开头的中文格式。

## 决策记录
### 决策 #17: 保持标识符英文，内容中文
**背景**: Skill 的 `name` 字段通常作为命令行或工具的唯一标识符。
**决策**: `name` 保持英文（workflow-management），其余描述和正文全部汉化。

## 下次从这里开始
### 继续工作
"替换 Skill 文件为中文版本"
