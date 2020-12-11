
FROM php:7.3.23-fpm-alpine

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories

# 安装依赖及部分扩展
RUN apk update \
    && apk add --no-cache --virtual .name gcc g++ autoconf make \
    && wget https://pecl.php.net/get/redis-5.3.2.tgz -O redis.tgz \
    && mkdir -p redis \
    && tar -xf redis.tgz -C redis --strip-components=1 \
    && rm redis.tgz \
    && ( \
        cd redis \
        && phpize \
        && ./configure --with-php-config=/usr/local/bin/php-config \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r redis \
    && docker-php-ext-enable redis \
    && apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev mysql-client \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-source delete \
    && cd /usr/local/etc/php \
    && touch php.ini \
    && apk del .name \
    && rm -rf /usr/src/* \ 
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/local/src/* \ 
    && rm -rf /tmp/pear/download/* \
    && rm -rf /tmp/pear/cache/*

    # && docker-php-ext-install pcntl \
    # && docker-php-ext-install -j$(nproc) iconv \
    # && docker-php-ext-install sockets zip sysvmsg \

EXPOSE 9000
