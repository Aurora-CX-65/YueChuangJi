# ============================================
# 阅创集 (YueChuangJi) 前端 Dockerfile
# Vue 3 + Vite + Nginx
# ============================================

# ---- 阶段一：Node 构建 ----
FROM node:22-alpine AS builder

WORKDIR /build

# 设置构建参数（API 地址，启动时通过 --build-arg 传入）
ARG VITE_API_BASE_URL=/api
ARG VITE_API_TIMEOUT=30000
ARG VITE_APP_TITLE=阅创集
ARG VITE_APP_VERSION=1.0.0

ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
ENV VITE_API_TIMEOUT=${VITE_API_TIMEOUT}
ENV VITE_APP_TITLE=${VITE_APP_TITLE}
ENV VITE_APP_VERSION=${VITE_APP_VERSION}

# 先复制依赖文件，利用 Docker 缓存层
COPY package*.json ./
RUN npm ci --registry=https://registry.npmmirror.com

# 复制源码并构建
COPY . .
RUN npm run build

# ---- 阶段二：Nginx 静态服务 ----
FROM nginx:alpine

# 删除默认配置
RUN rm -f /etc/nginx/conf.d/default.conf

# 复制自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 复制构建产物
COPY --from=builder /build/dist /usr/share/nginx/html

# 安全：以非 root 用户运行
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

EXPOSE 80

# 使用 nginx 官方镜像自带的非 root 用户
USER nginx

CMD ["nginx", "-g", "daemon off;"]
