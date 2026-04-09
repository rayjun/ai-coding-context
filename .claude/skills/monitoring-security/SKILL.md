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

## 快速参考
| 领域 | 规则 | 实施 |
|------|------|------|
| 认证 | 强制执行 | Basic Auth / Grafana RBAC |
| HTTPS | 必须 | TLS 1.2+, Nginx/Traefik |
| 网络 | 隔离 | 专用的 Docker 网络 |
| 密钥 | 严禁 Git | .env (已忽略) / Vault |

## 实施协议

### 第一步：网络隔离
创建专用 Docker 网络，确保监控服务不暴露在公网：
```yaml
# docker-compose.yml
networks:
  monitoring:
    driver: bridge
    internal: false
  monitoring-backend:
    driver: bridge
    internal: true

services:
  prometheus:
    image: prom/prometheus:latest
    user: "65534:65534"
    networks:
      - monitoring-backend
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
```

### 第二步：身份验证
Prometheus Basic Auth 配置：
```yaml
# web.yml (Prometheus)
basic_auth_users:
  admin: $2y$10$HASHED_PASSWORD  # 用 htpasswd -nBC 10 admin 生成
```
启动参数添加 `--web.config.file=/etc/prometheus/web.yml`。

Grafana RBAC 配置：
```ini
# grafana.ini
[auth]
disable_login_form = false
[auth.anonymous]
enabled = false
[security]
admin_password = ${GF_SECURITY_ADMIN_PASSWORD}
```

### 第三步：TLS 反向代理
```nginx
# nginx.conf
server {
    listen 443 ssl;
    server_name grafana.example.com;

    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        proxy_pass http://grafana:3000;
        proxy_set_header Host $host;
    }
}
```

### 第四步：密钥管理
```bash
# .env (必须在 .gitignore 中)
GF_SECURITY_ADMIN_PASSWORD=<生成强密码>
PROMETHEUS_BASIC_AUTH_PASS=<生成强密码>
ALERTMANAGER_WEBHOOK_SECRET=<生成强密码>
```
确认 `.gitignore` 包含 `.env`：
```bash
grep -q "^\.env$" .gitignore || echo ".env" >> .gitignore
```

### 第五步：验证
逐项检查部署安全性：
```bash
# 1. TLS 证书有效
curl -vI https://grafana.example.com 2>&1 | grep "SSL certificate verify ok"

# 2. HTTP 被拒绝或重定向
curl -I http://grafana.example.com 2>&1 | grep -E "301|403"

# 3. 认证生效（无凭据应返回 401）
curl -s -o /dev/null -w "%{http_code}" http://prometheus:9090/metrics
# 预期输出: 401

# 4. 安全头存在
curl -sI https://grafana.example.com | grep -i "strict-transport-security"

# 5. .env 未被 Git 追踪
git ls-files --error-unmatch .env 2>&1 | grep -q "error" && echo "PASS" || echo "FAIL"

# 6. 容器非 root 运行
docker exec prometheus id
# 预期: uid=65534(nobody)
```

## 常见错误
- 提交 .env 文件：导致凭据泄漏到 Git 历史。
- 使用默认密码：admin/admin 是最常见的漏洞。
- 生产环境使用 HTTP：使指标数据容易被窃听。
- 跳过验证步骤：部署后不检查 TLS 和认证是否真正生效。
