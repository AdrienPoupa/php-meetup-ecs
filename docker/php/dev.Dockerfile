FROM php:7.3-fpm-alpine

# Install PHPIZE_DEPS
RUN apk --no-cache add $PHPIZE_DEPS

# Set the workdir
WORKDIR /var/www/html

# Install the Redis extension
ENV REDIS_VERSION 4.0.2

# Install PHPRedis
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$REDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-* /usr/src/php/ext/redis

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql redis

# Install xDebug
COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d

ENV PHP_IDE_CONFIG="serverName=urlshortener"

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> /usr/local/etc/php/conf.d/xdebug.ini

# Script permission
COPY docker/php/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Run script
EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]
