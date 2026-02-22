
# -----------------------
# Stage 1: Build frontend
# -----------------------
FROM node:20-bullseye AS frontend

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --legacy-peer-deps

COPY . .

# ⭐ الحل هنا ⭐
ENV ROLLUP_SKIP_NATIVE=true

RUN npm run build


# -----------------------
# Stage 2: PHP backend
# -----------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . .

COPY --from=frontend /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

RUN php artisan storage:link || true

EXPOSE 8000

CMD ["php-fpm"]