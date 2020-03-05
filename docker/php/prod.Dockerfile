# Build Stage 1
# Compile Composer dependencies
FROM composer:latest AS composer
WORKDIR /var/www/html
COPY . /var/www/html
RUN composer install --ignore-platform-reqs --no-interaction --no-dev --prefer-dist --optimize-autoloader

# Build Stage 2
# Compile NPM assets
FROM node:12.13.0-alpine AS build-npm
WORKDIR /var/www/html
COPY --from=composer /var/www/html /var/www/html
RUN npm install --silent --no-progress
RUN npm run prod --silent --no-progress
RUN rm -rf node_modules

# Build Stage 3
# PHP Alpine image
FROM php:7.3-fpm-alpine

# Copy files from NPM
WORKDIR /var/www/html
COPY --from=build-npm /var/www/html /var/www/html

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

# Script permission
COPY docker/php/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Make the sourcecode available to the nginx container
VOLUME /var/www/html

# Run script
EXPOSE 9000
CMD ["/entrypoint.sh"]
