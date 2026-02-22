
# -----------------------
# Stage 1: Build frontend (Vite)
# -----------------------
FROM node:20-bullseye AS frontend

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build


# -----------------------
# Stage 2: PHP + Composer
# -----------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# تثبيت الامتدادات المطلوبة
RUN docker-php-ext-install pdo pdo_mysql

# تثبيت Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# نسخ ملفات Laravel فقط
COPY . .

# نسخ ملفات Vite المبنية فقط
COPY --from=frontend /app/public/build ./public/build

# تثبيت باكجات PHP
RUN composer install --no-dev --optimize-autoloader

# إعداد الصلاحيات
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# إنشاء storage link
RUN php artisan storage:link || true

EXPOSE 8000

CMD ["php-fpm"]