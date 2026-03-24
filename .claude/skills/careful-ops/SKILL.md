---
name: careful-ops
description: 执行破坏性或不可逆操作前使用，提供主动安全防护和确认机制。
---

# 破坏性操作防护 (Careful Ops)

## 概览
将被动的"小心操作"规则升级为主动防护机制。在执行高风险命令前强制触发警告、替代方案建议和确认流程。

## 何时使用
- 执行任何可能造成数据丢失或不可逆变更的操作。
- 操作生产环境或共享环境。
- 涉及数据库 DDL、Git 历史重写、容器/集群资源删除。

## 危险操作清单

### 数据库
| 操作 | 风险等级 | 替代方案 |
|------|---------|---------|
| `DROP TABLE / DATABASE` | CRITICAL | 先 `pg_dump` / `mysqldump` 备份 |
| `TRUNCATE` | CRITICAL | 先确认表名和行数，考虑软删除 |
| `ALTER TABLE` (生产) | HIGH | 使用 online DDL / `gh-ost` / `pt-online-schema-change` |
| `DELETE` 无 WHERE | CRITICAL | 强制要求 WHERE 条件，先 SELECT 确认范围 |
| `UPDATE` 无 WHERE | CRITICAL | 同上 |

### Git
| 操作 | 风险等级 | 替代方案 |
|------|---------|---------|
| `git reset --hard` | HIGH | `git stash` 或先创建备份分支 |
| `git push --force` | HIGH | `git push --force-with-lease` |
| `git rebase` (已推送) | HIGH | `git merge` 保留历史 |
| `git branch -D` | MEDIUM | 确认分支已合并 (`git branch --merged`) |

### 系统 / 容器
| 操作 | 风险等级 | 替代方案 |
|------|---------|---------|
| `rm -rf` | CRITICAL | 先 `ls` 确认路径，考虑 `trash-put` |
| `kubectl delete` (生产) | CRITICAL | 先 `kubectl get` 确认资源，使用 `--dry-run` |
| `docker rm -f` / `docker system prune` | HIGH | 先 `docker ps` / `docker images` 确认 |

## 执行协议

1. **识别**: 检测到危险操作时，立即暂停。
2. **警告**: 明确说明风险等级和可能后果。
3. **替代**: 给出更安全的替代方案。
4. **确认**: 等待用户明确确认后才执行。
5. **备份**: CRITICAL 级别操作执行前，建议先做备份。

## 快速参考
| 风险等级 | 行为 |
|---------|------|
| CRITICAL | 必须警告 + 建议备份 + 等待确认 |
| HIGH | 必须警告 + 给出替代 + 等待确认 |
| MEDIUM | 提示风险，可直接执行 |

## 常见错误
- 路径变量未展开就执行 `rm -rf $VAR/`：变量为空时删除根目录。
- 生产环境直接跑 DDL：未评估锁表时间和影响范围。
- `--force` 作为"修复"手段：掩盖了真正需要解决的冲突。
- 跳过 `--dry-run`：本可以零成本预览结果。
