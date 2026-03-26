#!/bin/sh
set -e

# 启动 PHP-FPM 并让其在后台运行
php-fpm -D

# 启动 Nginx 并保持在前台，防止容器退出
echo "Starting Nginx..."
nginx -g "daemon off;"
