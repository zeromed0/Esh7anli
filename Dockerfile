
# -----------------------
# Stage 1: Build frontend
# -----------------------
FROM node:18-bullseye AS frontend

WORKDIR /app

# نسخ package.json و package-lock.json
COPY package*.json ./

# تثبيت dependencies مع legacy peer deps
RUN npm install --legacy-peer-deps

# نسخ باقي ملفات المشروع
COPY . .

# إعداد متغيرات البيئة اللازمة للبناء
ENV APP_ENV=production
ENV APP_URL=https://2sh7anli.onrender.com

# Build assets
RUN npm run build

# -----------------------
# Stage 2: PHP backend
# -----------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# تثبيت الامتدادات المطلوبة
RUN docker-php-ext-install pdo pdo_mysql

# نسخ الملفات من Stage 1
COPY --from=frontend /app /var/www/html

# إعداد الصلاحيات
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 8000

CMD ["php-fpm"]