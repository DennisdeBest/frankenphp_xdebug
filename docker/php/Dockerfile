#syntax=docker/dockerfile:1.4

FROM dunglas/frankenphp:1.1.0-alpine AS frankenphp_upstream
FROM composer/composer:2-bin AS composer_upstream
FROM node:20-alpine AS node

# Base FrankenPHP image
FROM frankenphp_upstream AS frankenphp_base

WORKDIR /app

# persistent / runtime deps
# hadolint ignore=DL3018
RUN apk add --no-cache \
		acl \
		file \
		gettext \
		git \
	;

RUN set -eux; \
	install-php-extensions \
		apcu \
		intl \
		opcache \
		gd \
		xsl \
		zip \
    pdo_mysql \
	;

COPY --link docker/php/conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY --link --chmod=755 docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link docker/php/Caddyfile /etc/caddy/Caddyfile

ENTRYPOINT ["docker-entrypoint"]

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

COPY --from=composer_upstream --link /composer /usr/bin/composer

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]

# Dev FrankenPHP image
FROM frankenphp_base AS frankenphp_dev

ENV APP_ENV=dev
VOLUME /app/var/

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN apk add --no-cache gdb

RUN set -eux; \
	install-php-extensions \
		xdebug \
	;

COPY --link docker/php/conf.d/app.dev.ini $PHP_INI_DIR/conf.d/

ARG PHP_CS_FIXER_VERSION=v3.51.0

RUN wget "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/$PHP_CS_FIXER_VERSION/php-cs-fixer.phar" -O php-cs-fixer && \
    chmod a+x php-cs-fixer && \
    mv php-cs-fixer /usr/local/bin/php-cs-fixer

CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--watch" ]


FROM frankenphp_base AS composer_install

ENV APP_ENV=prod

COPY --link . ./
RUN rm -Rf docker/php/

RUN set -eux; \
	composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer dump-autoload --optimize --classmap-authoritative --no-dev; \
	composer dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; sync;

FROM composer_install AS fixtures

ENV APP_ENV=dev

RUN set -eux; \
	composer install --no-cache --no-progress

FROM node AS build_node

WORKDIR /app

COPY --from=composer_install /app /app

RUN yarn && yarn encore production

RUN rm -rf node_modules

# Prod FrankenPHP image
FROM frankenphp_base AS frankenphp_prod

ENV APP_ENV=prod
ENV FRANKENPHP_CONFIG="import worker.Caddyfile"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=build_node ./app ./

COPY --link docker/php/conf.d/app.prod.ini $PHP_INI_DIR/conf.d/
COPY --link docker/php/worker.Caddyfile /etc/caddy/worker.Caddyfile


