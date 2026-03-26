# 使用最新的 PHP 8.3 稳定版
FROM php:8.3-fpm-alpine

# 安装 Nginx 和 ThinkPHP 必要的系统依赖
RUN apk add --no-cache \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    oniguruma-dev \
    icu-dev

# 安装并启用 PHP 扩展 (MySQL, Redis, GD, intl 等)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        bcmath \
        intl \
        opcache \
    && pecl install redis \
    && docker-php-ext-enable redis

# 配置 PHP 生产环境优化 (开启 Opcache)
RUN printf "opcache.memory_consumption=128\nopcache.interned_strings_buffer=8\nopcache.max_accelerated_files=4000\nopcache.revalidate_freq=60\nopcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# 配置 Nginx
COPY nginx.conf /etc/nginx/http.d/thinkphp.conf
RUN rm /etc/nginx/http.d/default.conf

WORKDIR /var/www/html
COPY . .

# 权限处理：ThinkPHP 8 需要对 runtime 和 public/uploads 有写入权
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/runtime

# 复制启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]
