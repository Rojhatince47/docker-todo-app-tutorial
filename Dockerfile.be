FROM ubuntu:22.04

LABEL maintainer="rojhat@example.com"
LABEL description="Apache / PHP development environment"

ARG DEBIAN_FRONTEND=noninteractive

# Sistem güncellemesi + gerekli araçlar
RUN apt-get update && apt-get install -y \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    gnupg \
    && add-apt-repository ppa:ondrej/php -y

# PHP 8.2 ve Apache kurulumu
RUN apt-get update && apt-get install -y \
    apache2 \
    php8.2 \
    libapache2-mod-php8.2 \
    php8.2-bcmath \
    php8.2-gd \
    php8.2-sqlite3 \
    php8.2-mysql \
    php8.2-curl \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    nano \
    && apt-get clean

# PHP hata ayarları (geliştirme ortamı)
RUN sed -i "s/^error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.2/apache2/php.ini \
 && sed -i "s/^display_errors = .*/display_errors = On/" /etc/php/8.2/apache2/php.ini

# Apache ayarları
RUN a2enmod rewrite \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# İzinler
RUN chgrp -R www-data /var/www && \
    find /var/www -type d -exec chmod 775 {} + && \
    find /var/www -type f -exec chmod 664 {} +

EXPOSE 80
COPY ./api /var/www/html/
RUN rm -rf /var/www/html/index.html
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
