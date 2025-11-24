# 1) استخدام صورة PHP مع Composer و Node مدمجين
FROM richarvey/nginx-php-fpm:3.1.2

# تفعيل أوامر النظام
USER root

# 2) تثبيت Node 18 (يدعم Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# 3) تحديد مجلد المشروع داخل الحاوية
WORKDIR /var/www/html

# 4) نسخ مشروع Laravel كاملًا
COPY . .

# 5) تثبيت باقات PHP (Laravel)
RUN composer install --no-dev --optimize-autoloader

# 6) تثبيت باقات Vue (npm)
RUN npm install
RUN npm run build

# 7) إعداد الصلاحيات للمجلدات المهمة
RUN chown -R www-data:www-data storage bootstrap/cache

# 😎 كشف البورت
EXPOSE 80