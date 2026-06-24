# 阅创集 (YueChuangJi) Docker 容器化部署指南

## 目录

- [快速开始（本地开发）](#快速开始本地开发)
- [公网部署（IP 访问）](#公网部署ip-访问)
- [公网部署（域名 + HTTPS）](#公网部署域名--https)
- [管理命令](#管理命令)
- [架构说明](#架构说明)
- [常见问题](#常见问题)

---

## 快速开始（本地开发）

### 前置条件

- Docker ≥ 20.10
- Docker Compose ≥ 2.0

### 1. 配置环境变量

```bash
cp .env.docker .env
```

### 2. 启动所有服务

```bash
docker compose up -d --build
```

### 3. 访问

| 服务 | 地址 |
|------|------|
| 前端 | http://localhost |
| Swagger | http://localhost/swagger-ui/index.html |
| Actuator | http://localhost:8080/actuator/health |

---

## 公网部署（IP 访问）

适用于：有公网 IP 但没有域名的云服务器。

### 1. 修改 `.env`

```env
DEPLOY_MODE=production

# 替换为你的服务器公网 IP
PUBLIC_DOMAIN=123.45.67.89
FILE_ACCESS_BASE_URL=http://123.45.67.89

# 安全配置 ⚠️
DB_ROOT_PASSWORD=你的强密码
REDIS_PASSWORD=你的Redis密码
JWT_SECRET=$(openssl rand -base64 64)

# 不启用 SSL（IP 无法申请免费证书）
ENABLE_SSL=false
```

### 2. 防火墙开放端口

```bash
# 只需开放 80 端口（前端）
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload
```

> ⚠️ **安全提示**：不要开放 3306（MySQL）、6379（Redis）、8080（后端）端口！

### 3. 启动生产环境

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

### 4. 访问

浏览器打开 `http://你的公网IP` 即可访问。

---

## 公网部署（域名 + HTTPS）

适用于：有域名的生产环境，推荐通过 Nginx 反向代理统一对外。

### 第一步：域名解析

将域名 DNS A 记录指向服务器 IP：

| 类型 | 主机记录 | 记录值 |
|------|---------|--------|
| A | @ | 你的服务器 IP |
| A | www | 你的服务器 IP |

### 第二步：修改 `.env`

```env
DEPLOY_MODE=production

# 域名配置
PUBLIC_DOMAIN=yuechuangji.com
PROTOCOL=https
FILE_ACCESS_BASE_URL=https://yuechuangji.com
VITE_API_BASE_URL=/api

# 安全配置 ⚠️ 务必修改！
DB_ROOT_PASSWORD=你的强密码
REDIS_PASSWORD=你的Redis密码
JWT_SECRET=$(openssl rand -base64 64)

ENABLE_SSL=false   # 先 false，获取证书后再开启
```

### 第三步：首次启动（HTTP 模式）

```bash
# 先以 HTTP 模式启动，后续再启用 HTTPS
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

### 第四步：获取 SSL 证书

```bash
# 1. 停止 Nginx 释放 80 端口
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop frontend

# 2. 使用 Certbot 获取免费证书
bash setup-ssl.sh yuechuangji.com admin@yuechuangji.com

# 3. 启用 HTTPS
# 编辑 .env，修改：
#   ENABLE_SSL=true
#   PROTOCOL=https
#   FILE_ACCESS_BASE_URL=https://yuechuangji.com

# 4. 重新构建启动
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

### 第五步：配置证书自动续期

```bash
# 添加 crontab 定时任务（每天凌晨 3 点检查续期）
(crontab -l 2>/dev/null; echo "0 3 * * * docker run --rm -v $(pwd)/docker/nginx/ssl:/etc/letsencrypt -p 80:80 certbot/certbot renew --quiet && docker compose -f $(pwd)/docker-compose.yml -f $(pwd)/docker-compose.prod.yml restart frontend") | crontab -
```

### 第六步：访问

浏览器打开 `https://yuechuangji.com`。

---

## 关键配置说明

### 环境变量完整说明

| 变量 | 说明 | 示例 |
|------|------|------|
| `PUBLIC_DOMAIN` | 公网域名或 IP | `yuechuangji.com` 或 `123.45.67.89` |
| `PROTOCOL` | 访问协议 | `http` 或 `https` |
| `ENABLE_SSL` | 是否启用 HTTPS | `true` / `false` |
| `FILE_ACCESS_BASE_URL` | 上传文件外部访问 URL | `https://yuechuangji.com` |
| `DB_ROOT_PASSWORD` | MySQL root 密码 | 强密码 |
| `REDIS_PASSWORD` | Redis 密码 | 强密码 |
| `JWT_SECRET` | JWT 签名密钥 | `openssl rand -base64 64` |
| `DEEPSEEK_API_KEY` | DeepSeek API Key | `sk-xxx` |
| `MAIL_*` | SMTP 邮件配置 | 可选 |

### 端口映射

| 端口 | 服务 | 开发环境 | 生产环境 |
|------|------|---------|---------|
| 80 | 前端 (Nginx) | ✅ 开放 | ✅ 开放 |
| 443 | 前端 (HTTPS) | ❌ | ✅ 开放（SSL 启用时）|
| 3306 | MySQL | ✅ 开放 | ⚠️ 仅 127.0.0.1 |
| 6379 | Redis | ✅ 开放 | ⚠️ 仅 127.0.0.1 |
| 8080 | 后端 API | ✅ 开放 | ⚠️ 仅 127.0.0.1 |

---

## 管理命令

```bash
# === 基础命令 ===

# 开发环境启动
docker compose up -d --build

# 生产环境启动
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# 停止
docker compose down

# 停止并清理数据卷（⚠️ 数据库清空！）
docker compose -f docker-compose.yml -f docker-compose.prod.yml down -v

# === 查看状态 ===

docker compose ps                          # 服务状态
docker compose logs -f backend             # 后端日志
docker compose logs -f --tail 100 frontend # 前端最后 100 行日志
docker compose stats                       # 资源使用

# === 重启 ===

docker compose restart backend             # 仅重启后端
docker compose restart frontend            # 仅重启前端

# === 重新构建 ===

docker compose build backend --no-cache    # 强制重建后端
docker compose up -d --no-deps backend     # 热更新后端

# === 数据库 ===

# 进入 MySQL
docker compose exec mysql mysql -uroot -p

# 备份数据库
docker compose exec mysql mysqldump -uroot -p yuechuangji > backup_$(date +%Y%m%d).sql

# 恢复数据库
docker compose exec -T mysql mysql -uroot -p yuechuangji < backup_20260624.sql

# === 调试 ===

docker compose exec backend sh             # 进入后端容器
docker compose exec frontend sh            # 进入前端容器
docker compose exec redis redis-cli        # 进入 Redis CLI
```

---

## 架构说明

```
                   ┌─────────────────────────────────────┐
                   │              公网用户                  │
                   └──────────────┬──────────────────────┘
                                  │ HTTP(:80) / HTTPS(:443)
                                  ▼
                   ┌─────────────────────────────────────┐
                   │   Frontend (Nginx)                   │
                   │   - 静态文件服务 + SPA 路由            │
                   │   - SSL 终结                         │
                   │   - /api/* → backend:8080            │
                   │   - /actuator/* → 仅内网              │
                   └──────────────┬──────────────────────┘
                                  │ /api/* (Docker 内部网络)
                                  ▼
                   ┌─────────────────────────────────────┐
                   │   Backend (Spring Boot)              │
                   │   :8080 (仅 127.0.0.1 绑定)          │
                   │   - REST API                         │
                   │   - JWT 认证                          │
                   │   - 文件上传                           │
                   └──────┬──────────┬───────────────────┘
                          │          │
                   ┌──────▼──┐  ┌───▼───────┐
                   │  MySQL  │  │   Redis   │
                   │  :3306  │  │   :6379   │
                   │(仅本地)  │  │ (仅本地)   │
                   └─────────┘  └───────────┘
```

## 目录结构

```
├── docker-compose.yml              # 基础编排文件
├── docker-compose.prod.yml         # 生产环境覆盖
├── .env.docker                     # 环境变量模板
├── .env                            # 你的配置（不提交 Git）
├── setup-ssl.sh                    # SSL 证书获取脚本
├── DOCKER.md                       # 本文档
├── docker/
│   ├── mysql/
│   │   └── conf.d/
│   │       └── custom.cnf          # MySQL 优化配置
│   └── nginx/
│       ├── ssl/                    # SSL 证书目录
│       │   ├── README.txt
│       │   ├── fullchain.pem        # （部署时放入）
│       │   └── privkey.pem          # （部署时放入）
│       └── certbot/                # Certbot 验证文件
├── YueChuangJiApi/
│   ├── Dockerfile                  # 后端开发用 Dockerfile
│   └── .dockerignore
└── YueChuangJiUI/
    ├── Dockerfile                  # 前端开发用 Dockerfile
    ├── Dockerfile.prod             # 前端生产用 Dockerfile（支持 SSL）
    ├── nginx.conf                  # 开发用 Nginx 配置
    ├── nginx.template.conf         # Nginx 模板（envsubst）
    ├── nginx-prod.conf             # 生产 SSL Nginx 配置模板
    ├── docker-entrypoint.sh        # 容器启动脚本
    └── .dockerignore
```

## 常见问题

### Q: 如何用 IP 直接部署？

修改 `.env` 中 `PUBLIC_DOMAIN` 为你的公网 IP，`ENABLE_SSL=false`。注意：IP 部署无法使用 HTTPS（浏览器会报证书错误），如需 HTTPS 建议购买域名。

### Q: 端口冲突怎么办？

修改 `.env`：
```env
FRONTEND_EXPOSE_PORT=8081
BACKEND_EXPOSE_PORT=8082
```

### Q: 数据库初始化失败？

```bash
# 检查 SQL 脚本
docker compose exec mysql mysql -uroot -p
# 手动导入
source /docker-entrypoint-initdb.d/01_init_database.sql
```

### Q: 前端请求 502？

```bash
docker compose logs backend | grep "Started YueChuangJiApiApplication"
```
确认后端已成功启动。

### Q: SSL 证书到期怎么办？

Certbot 证书有效期为 90 天，设置 crontab 自动续期后无需手动处理。如需手动续期：
```bash
bash setup-ssl.sh yuechuangji.com admin@yuechuangji.com
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart frontend
```

### Q: 生产环境安全建议？

1. 务必修改 `DB_ROOT_PASSWORD`、`REDIS_PASSWORD`、`JWT_SECRET`
2. 不要在 `.env` 中提交到 Git（已在 `.gitignore` 排除）
3. 限制服务器防火墙仅开放 80/443 端口
4. 定期备份数据库
5. 使用非 root 用户运行 Docker（已配置）
