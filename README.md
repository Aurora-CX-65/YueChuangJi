# 阅创集 (YueChuangJi)

智能体内容创作助手 —— 创作与阅读一体化平台，融合 DeepSeek LLM 与通义千问 VL，提供 AI 驱动的智能化内容创作体验。

## 项目概览

阅创集是一款 AI Agent 应用，采用前后端分离架构，具备工具调用（Tool Calling）能力，专注于智能化内容创作场景。

| 模块 | 说明 | 仓库 |
|------|------|------|
| 后端 API | Spring Boot RESTful 服务 | [YueChuangJiApi](https://github.com/Aurora-CX-65/YueChuangJiApi) |
| 前端 UI | Vue 3 + Vite 单页应用 | [YueChuangJiUI](https://github.com/Aurora-CX-65/YueChuangJiUI) |
| 接口文档 | API 规范与变更日志 | [doc/接口文档](doc/接口文档/) |

## 技术栈

**后端**
- Spring Boot 3.5 / MyBatis-Plus / Spring Security + JWT
- MySQL 8.0 / Redis / DeepSeek AI / 通义千问 VL
- Swagger/OpenAPI 3.0

**前端**
- Vue 3 / Vite / TypeScript
- 全中文 UI 本地化

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

## 目录结构

```
YueChuangJi/
├── YueChuangJiApi/       ← 后端（Submodule）
├── YueChuangJiUI/        ← 前端（Submodule）
├── doc/
│   ├── 接口文档/          ← API 规范与变更日志
│   └── ...               ← 其他项目文档
├── .gitignore
├── .gitmodules
└── README.md
```
