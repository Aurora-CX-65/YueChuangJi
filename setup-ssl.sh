#!/bin/bash
# ============================================
# 阅创集 Let's Encrypt SSL 证书获取脚本
# ============================================
# 使用方式:
#   1. 确保域名 DNS 已解析到本服务器 IP
#   2. 确保 80 端口未被占用（先停止 Nginx）
#   3. 运行: bash setup-ssl.sh your-domain.com your-email@example.com
# ============================================

set -e

if [ $# -lt 2 ]; then
    echo "用法: bash setup-ssl.sh <域名> <邮箱>"
    echo "示例: bash setup-ssl.sh yuechuangji.com admin@yuechuangji.com"
    exit 1
fi

DOMAIN=$1
EMAIL=$2
SSL_DIR="$(cd "$(dirname "$0")" && pwd)/docker/nginx/ssl"

echo "============================================"
echo "  阅创集 SSL 证书获取"
echo "  域名: ${DOMAIN}"
echo "  邮箱: ${EMAIL}"
echo "============================================"

# 检查 80 端口
if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "!!! 错误: 80 端口已被占用"
    echo "请先停止占用 80 端口的服务，或在 docker-compose 中注释掉 frontend 的 80 端口映射"
    exit 1
fi

# 使用 Docker Certbot 获取证书
echo ">>> 正在获取 SSL 证书..."
docker run --rm \
    -v "${SSL_DIR}:/etc/letsencrypt" \
    -p 80:80 \
    certbot/certbot \
    certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email "${EMAIL}" \
    -d "${DOMAIN}" \
    --preferred-challenges http

# 复制证书到正确位置
LETSENCRYPT_DIR="${SSL_DIR}/live/${DOMAIN}"
if [ -d "${LETSENCRYPT_DIR}" ]; then
    cp "${LETSENCRYPT_DIR}/fullchain.pem" "${SSL_DIR}/fullchain.pem"
    cp "${LETSENCRYPT_DIR}/privkey.pem" "${SSL_DIR}/privkey.pem"
    chmod 644 "${SSL_DIR}/fullchain.pem"
    chmod 600 "${SSL_DIR}/privkey.pem"

    echo "============================================"
    echo "  SSL 证书获取成功！"
    echo "  fullchain.pem -> ${SSL_DIR}/fullchain.pem"
    echo "  privkey.pem   -> ${SSL_DIR}/privkey.pem"
    echo "============================================"
    echo ""
    echo "下一步:"
    echo "  1. 编辑 .env，设置:"
    echo "     PUBLIC_DOMAIN=${DOMAIN}"
    echo "     ENABLE_SSL=true"
    echo "     PROTOCOL=https"
    echo "     FILE_ACCESS_BASE_URL=https://${DOMAIN}"
    echo ""
    echo "  2. 重新构建并启动:"
    echo "     docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build"
    echo ""
    echo "  3. 证书自动续期（添加到 crontab）:"
    echo "     0 3 * * * docker run --rm -v ${SSL_DIR}:/etc/letsencrypt -p 80:80 certbot/certbot renew --quiet"
else
    echo "!!! 错误: 证书获取失败，请检查域名 DNS 解析和网络连通性"
    exit 1
fi
