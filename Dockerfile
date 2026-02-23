
# Stage 1: Build frontend (Vite)
FROM node:18-bullseye AS frontend

WORKDIR /app

ENV ROLLUP_SKIP_NATIVE=true
ENV NODE_ENV=production

COPY package.json package-lock.json ./

RUN npm cache clean --force \
 && npm ci --legacy-peer-deps --omit=optional

COPY . .

RUN npm run build

# Stage 2: PHP backend
FROM php:8.2-fpm

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . .

COPY --from=frontend /app/dist ./public/build

RUN composer install --no-dev --optimize-autoloader \
 && chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html \
 && php artisan storage:link || true

EXPOSE 8000
CMD ["php-fpm"]