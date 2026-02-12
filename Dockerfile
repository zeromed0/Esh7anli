
# -----------------------
# Stage 1: Build frontend
# -----------------------
FROM node:18-alpine AS frontend

WORKDIR /app

# نسخ package.json و package-lock.json فقط أولاً لتسريع الـ cache
COPY package*.json ./

# تثبيت الحزم مع تجاهل peer dependency conflicts
RUN npm install --legacy-peer-deps

# نسخ باقي ملفات المشروع
COPY . .

# بناء الـ assets (Vite build)
RUN npm run build

# -----------------------
# Stage 2: PHP backend
# -----------------------
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# تثبيت الامتدادات المطلوبة للـ Laravel
RUN docker-php-ext-install pdo pdo_mysql

# نسخ المشروع من Stage 1
COPY --from=frontend /app /var/www/html

# نسخ مجلد الـ build من Vite إلى public (إن لم يكن داخل /public)
# COPY --from=frontend /app/public/build /var/www/html/public/build

# إعداد الصلاحيات
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 8000

CMD ["php-fpm"]