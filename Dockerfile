# 使用 PHP 8.3 FPM Alpine 作为基础镜像
FROM php:8.3-fpm-alpine

# 1. 设置工作目录 (ThinkPHP 的根目录)
WORKDIR /var/www/html

# 2. 安装系统依赖 & Nginx & 编译工具
RUN apk add --no-cache \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libavif-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    oniguruma-dev \
    icu-dev \
    $PHPIZE_DEPS

# 3. 编译并安装 PHP 核心扩展 (利用 80 核多进程编译)
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        bcmath \
        intl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del $PHPIZE_DEPS

# 4. 安装 Composer (用于管理 ThinkPHP 依赖)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. 【核心步骤】将当前目录下的所有文件拷贝到镜像的网站目录
# 请确保你的 Dockerfile 放在项目根目录下
COPY . /var/www/html

# 6. 安装 PHP 依赖 (针对生产环境优化)
# 如果你已经在本地运行过 composer install，这步可以跳过或保留以确保镜像完整性
# RUN composer install --no-dev --optimize-autoloader

# 7. 配置文件与权限处理
# 拷贝 Nginx 配置和启动脚本
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# 赋予脚本执行权限，并递归修复 ThinkPHP 目录权限
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /var/www/html/runtime \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/runtime

# 8. 暴露端口与启动
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
