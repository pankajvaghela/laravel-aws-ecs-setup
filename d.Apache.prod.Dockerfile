FROM php:7.4-apache

# ARG PHP_VERSION=7.4
# ENV PHP_VERSION ${PHP_VERSION}

ENV DEBIAN_FRONTEND noninteractive

# Set working directory
WORKDIR /var/www


# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    mcrypt \
    curl
# php7.4-gd \
# php7.4-xml \
# php7.4-gmp \
# php7.4-zip \
# php7.4-curl \
# php7.4-redis \
# php7.4-mbstring \
# php7.4-xml \
# php7.4-opcache \
# php7.4-bcmath

# Clear cache
RUN apt-get install -y libzip-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# enabled rewrite extension on apahce
RUN a2enmod rewrite

COPY docker/docker-entrypoint-apache.sh /etc/entrypoint.sh

# Copy existing application directory contents
COPY . /var/www/


COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
# COPY .env.example /var/www/.env
RUN chmod 777 -R /var/www/storage/ && \
#     echo "Listen 80" >> /etc/apache2/ports.conf && \
    chown -R www-data:www-data /var/www/


RUN php -r "file_exists('.env') || copy('.env.example.prod', '.env');"
# RUN composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist
RUN php artisan key:generate

# Copy existing application directory permissions
# COPY --chown=www:www . /var/www

# RUN chmod +x /etc/entrypoint.sh
# Change current user to www
# USER www

# Expose port 9000 and start php-fpm server
EXPOSE 80
# CMD ["php-fpm"]


# USER www

# ENTRYPOINT ["sh", "/etc/entrypoint.sh"]
