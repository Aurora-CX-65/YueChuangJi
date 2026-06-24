# ============================================
# SSL 证书目录
# ============================================
# 将以下文件放入此目录：
#
#   fullchain.pem  - 完整的证书链文件
#   privkey.pem    - 私钥文件
#
# 获取免费 SSL 证书（Let's Encrypt）：
#   https://letsencrypt.org/zh-cn/getting-started/
#
# 推荐使用 Certbot：
#   certbot certonly --standalone -d your-domain.com
#   cp /etc/letsencrypt/live/your-domain.com/fullchain.pem docker/nginx/ssl/
#   cp /etc/letsencrypt/live/your-domain.com/privkey.pem docker/nginx/ssl/
#
# 或使用 acme.sh（支持更多 DNS API）：
#   https://github.com/acmesh-official/acme.sh
# ============================================
