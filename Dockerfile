
# ===============================
# Stage 1: Frontend (Node 20)
# ===============================
FROM node:20.19.0-bullseye AS frontend

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --legacy-peer-deps

COPY . .

ENV NODE_ENV=production

RUN npm run build


# ===============================
# Stage 2: Backend (PHP)
# ===============================
FROM php:8.2-fpm

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

COPY --from=frontend /app /var/www/html

RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

EXPOSE 8000
CMD ["php-fpm"]