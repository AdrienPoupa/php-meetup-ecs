#!/bin/sh

# Read .env file while ignoring comment lines
export $(cat .env | sed 's/#.*//g' | xargs)

# Cache for production
if [ "$APP_ENV" = "production" ]; then
    php artisan route:cache --quiet
    php artisan config:cache --quiet
fi

# Migrations
php artisan migrate --force

# Launch PHP FPM
exec /usr/local/sbin/php-fpm
