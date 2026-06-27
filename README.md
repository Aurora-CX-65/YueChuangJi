# 阅创集 (YueChuangJi)

创作与阅读一体化平台，融合 DeepSeek LLM 驱动的智能化内容创作体验。

## 项目概览

阅创集是一款 Web 应用，采用前后端分离架构，具备 AI 辅助创作能力，专注于智能化内容创作场景。

| 模块 | 说明 | 仓库 |
|------|------|------|
| 后端 API | Spring Boot RESTful 服务 | [YueChuangJiApi](https://github.com/Aurora-CX-65/YueChuangJiApi) |
| 前端 UI | Vue 3 + Vite 单页应用 | [YueChuangJiUI](https://github.com/Aurora-CX-65/YueChuangJiUI) |
| 接口文档 | API 规范与变更日志 | [doc/接口文档](doc/接口文档/) |

## 技术栈

**后端**
- Spring Boot 3.5 / MyBatis-Plus / Spring Security + JWT
- MySQL 8.0 / Redis / Druid 连接池
- DeepSeek AI / OkHttp
- Swagger/OpenAPI 3.0 (springdoc)

**前端**
- Vue 3 / Vite / JavaScript
- Pinia 状态管理 / Vue Router
- Element Plus UI / TinyMCE 富文本编辑器

## 快速开始

### 克隆项目（含子模块）

```bash
git clone --recurse-submodules git@github.com:Aurora-CX-65/YueChuangJi.git
```

已有仓库但子模块缺失时：

```bash
git submodule update --init --recursive
```

### 后端

```bash
cd YueChuangJiApi
# 配置 application.yml 中的数据库、Redis、AI 服务密钥
mvn spring-boot:run
```

### 前端

```bash
cd YueChuangJiUI
npm install
npm run dev
```

### Docker 部署

项目支持 Docker Compose 一键部署：

```bash
# 复制并修改环境变量
cp .env.docker .env
# 编辑 .env 中的敏感信息（密码、API Key 等）

# 本地开发模式
docker compose up -d

# 生产模式
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

> 详细说明请参考 [DOCKER.md](DOCKER.md)

## 目录结构

```
YueChuangJi/
├── YueChuangJiApi/       ← 后端（Submodule）
├── YueChuangJiUI/        ← 前端（Submodule）
├── doc/
│   ├── 接口文档/          ← API 规范与变更日志
│   └── ...               ← 其他项目文档
├── .env.docker           ← Docker 环境变量模板
├── .gitignore
├── .gitmodules
├── DOCKER.md             ← Docker 部署说明
└── README.md
```
