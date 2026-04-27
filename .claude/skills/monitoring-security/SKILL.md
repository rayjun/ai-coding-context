---
name: monitoring-security
description: 当部署 Prometheus、Grafana 或 Alertmanager 等监控基础设施时使用，以确保安全加固和凭据保护。
---

# 监控安全 (Monitoring Security)

## 概览
通过身份验证、传输加密和最小权限原则来保护监控基础设施的安全框架。

## 何时使用
- 部署监控技术栈 (Prometheus, Grafana, Alertmanager)。
- 为监控服务配置反向代理。
- 对现有的监控安装进行安全加固。

## 核心模式
- **身份验证**: 所有端点必须强制登录 (Basic Auth 或 SSO)。
- **HTTPS/TLS**: 生产环境强制使用 TLS 1.2+。
- **最小权限**: 应用 RBAC 和限制性的网络访问。
- **密钥管理**: 严禁将凭据提交到版本控制。

## 快速参考
| 领域 | 规则 | 实施 |
|------|------|------|
| 认证 | 强制执行 | Basic Auth / Grafana RBAC |
| HTTPS | 必须 | TLS 1.2+, Nginx/Traefik |
| 网络 | 隔离 | 专用的 Docker 网络 |
| 密钥 | 严禁 Git | .env (已忽略) / Vault |

## 实施
1. 通过反向代理强制执行 HTTPS。
2. 将密码存储在环境变量中。
3. 在容器环境中使用非 root 用户运行。
4. 添加安全响应头 (X-Frame-Options, HSTS)。

## 常见错误
- 提交 .env 文件：导致凭据泄漏到 Git 历史。
- 使用默认密码：admin/admin 是最常见的漏洞。
- 生产环境使用 HTTP：使指标数据容易被窃听。
- 生产环境使用自签名证书：破坏了信任链。

## 质量评估标准

以下为二元（pass/fail）评估项，用于验证本 skill 输出质量。可配合 autoresearch 工具自动化运行。

```
EVAL 1: 认证强制
问题: 所有监控端点（Prometheus / Grafana / Alertmanager）是否都配置了强制认证？
Pass: 每个暴露的端点都有 Basic Auth / OAuth / Grafana RBAC 的配置证据
Fail: 存在任何未加认证的端点，或只做了"隐藏 URL"

EVAL 2: TLS 覆盖
问题: 生产配置是否强制 TLS 1.2+ 且不接受 HTTP 回退？
Pass: 反向代理配置中 listen 443 ssl + 强制重定向，且禁用 TLS 1.0/1.1
Fail: 存在明文端口，或 TLS 版本允许 1.0/1.1

EVAL 3: 密钥不入 Git
问题: 所有密码/token 是否通过 env / secret manager 注入，而非写入 docker-compose.yml / 配置文件？
Pass: 配置文件只引用 ${VAR}；.env 在 .gitignore 中；git log 无凭据历史
Fail: 明文密码出现在任何 tracked 文件中

EVAL 4: 最小权限
问题: 容器是否以非 root 用户运行，且网络仅暴露必要端口？
Pass: Dockerfile 中有 USER 指令，ports 只开反向代理入口
Fail: 以 root 运行，或直接暴露 9090/3000/9093 到公网

EVAL 5: 安全响应头
问题: 反向代理是否配置了 X-Frame-Options / HSTS / X-Content-Type-Options？
Pass: 配置中明确包含这 3 个头
Fail: 缺失任何一个关键安全头
```
