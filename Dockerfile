FROM php:8.3-fpm-alpine

# 更新软件源并安装编译所需的依赖
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
    $PHPIZE_DEPS # 包含 pecl 编译所需的 gcc, make, autoconf 等

# 编译安装扩展
# 注意：PHP 8.x 的 gd 配置参数有微调
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
        opcache \
    && pecl install redis \
    && docker-php-ext-enable redis \
    # 安装完成后清理编译依赖，减小镜像体积
    && apk del .build-deps || true
