
# =========================
# Laravel + Apache
# =========================
FROM php:8.2-apache

# System dependencies
# تثبيت دعم PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
  && docker-php-ext-install pdo pdo_pgsql zip \
    unzip \
    git \
    && a2enmod rewrite

# Set Apache DocumentRoot to Laravel public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

# Working directory
WORKDIR /var/www/html

# Copy composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Clear Laravel caches (بدون تشغيل السيرفر)
RUN php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear

EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
