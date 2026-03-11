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
