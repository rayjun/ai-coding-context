---
name: monitoring-security
description: Use when deploying monitoring infrastructure such as Prometheus, Grafana, or Alertmanager to ensure security hardening and credential protection.
---

# Monitoring Security

## Overview
A framework for securing monitoring infrastructure through authentication, transmission encryption, and the principle of least privilege.

## When to Use
- Deploying monitoring stacks (Prometheus, Grafana, Alertmanager).
- Configuring reverse proxies for monitoring services.
- Hardening existing monitoring installations.

## Core Pattern
- **Authentication**: Require login for all endpoints (Basic Auth or SSO).
- **HTTPS/TLS**: Enforce TLS 1.2+ for production data transmission.
- **Least Privilege**: Apply RBAC and restricted network access.
- **Secret Management**: Prevent committing credentials to version control.

## Quick Reference
| Area | Rule | Implementation |
|------|------|----------------|
| Auth | Mandatory | Basic Auth / Grafana RBAC |
| HTTPS | Required | TLS 1.2+, Nginx/Traefik |
| Network | Isolation | Dedicated Docker network |
| Secrets | No Git | .env (ignored) / Vault |

## Implementation
1. Enforce HTTPS via reverse proxy.
2. Store passwords in environment variables.
3. Use non-root users in container environments.
4. Add security headers (X-Frame-Options, HSTS).

## Common Mistakes
- Committing .env files: Leaks credentials to Git history.
- Using default passwords: admin/admin is a common vulnerability.
- Using HTTP for production: Exposes metrics to eavesdropping.
- Using self-signed certificates in production: Compromises chain of trust.
