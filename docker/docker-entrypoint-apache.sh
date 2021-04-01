#!/usr/bin/env sh

cd /var/www
php -r "file_exists('.env') || copy('.env.example', '.env');"
composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist
php artisan key:generate
# php artisan jwt:secret
