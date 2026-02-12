
# -------- Stage 1: Build Frontend --------
FROM node:18 as nodebuilder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


# -------- Stage 2: PHP + Nginx --------
FROM webdevops/php-nginx:8.2

WORKDIR /app

COPY . .

# انسخ ملفات Vite المبنية من المرحلة الأولى
COPY --from=nodebuilder /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader

RUN php artisan config:clear
RUN php artisan cache:clear

CMD ["supervisord"]