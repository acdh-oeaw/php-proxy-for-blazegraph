FROM composer:2 AS composer

FROM php:8.5-apache-trixie AS dependencies
WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

COPY composer.json composer.lock ./
RUN composer --no-interaction validate --strict \
    && composer --no-interaction install --no-dev --prefer-dist --optimize-autoloader \
    && composer --no-interaction check-platform-reqs --no-dev

FROM php:8.5-apache-trixie

ENV PORT=5000 \
    WEB_CONCURRENCY=8
WORKDIR /app

COPY --from=dependencies /app/vendor ./vendor
COPY index.php clearCache.php kubernetesCheck.sh ./
COPY docker/php.ini /usr/local/etc/php/conf.d/zz-proxy.ini
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite \
    && printf 'Listen ${PORT}\n' > /etc/apache2/ports.conf \
    && install -d -o www-data -g www-data -m 0750 /app/cache \
    && install -o www-data -g www-data -m 0640 /dev/null /app/log.csv \
    && apache2ctl configtest \
    && php -l index.php \
    && php -l clearCache.php

EXPOSE 5000
