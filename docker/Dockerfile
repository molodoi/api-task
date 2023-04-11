FROM php:8.1-apache

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
  \
  &&  apt-get update \
  &&  apt-get install -y --no-install-recommends \
  libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
  jpegoptim optipng pngquant gifsicle \
  locales apt-utils git libicu-dev g++ libpng-dev libxml2-dev libzip-dev libonig-dev libxslt-dev unzip \
  \
  &&  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen  \
  &&  echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
  &&  locale-gen \
  \
  &&  curl -sS https://getcomposer.org/installer | php -- \
  &&  mv composer.phar /usr/local/bin/composer \
  \
  && curl -sL https://deb.nodesource.com/setup_18.x | bash \
  && apt-get install nodejs \
  \
  &&  curl -sS https://get.symfony.com/cli/installer | bash \
  &&  mv /root/.symfony5/bin/symfony /usr/local/bin \
   \ 
  &&  docker-php-ext-configure \
  gd --with-jpeg=/usr/include \
  && docker-php-ext-configure intl \
  &&  docker-php-ext-install \
  pdo pdo_mysql opcache intl zip calendar dom mbstring -j$(nproc) gd xsl \
  \
  &&  pecl install apcu && docker-php-ext-enable apcu


WORKDIR /var/www/

RUN addgroup --system molodoi --gid 1000 && adduser --system molodoi --uid 1000 --ingroup molodoi
