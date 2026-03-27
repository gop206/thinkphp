FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

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

    apk del .build-deps && \
    rm -rf /tmp/pear && \
    docker-php-source delete && \
    rm -rf /var/cache/apk/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY t100.php /var/www/html

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /var/www/html/runtime \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/runtime

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
