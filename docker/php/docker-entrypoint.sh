#!/bin/sh

setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var

if [ "$1" = 'frankenphp' ]; then
  if [ "$APP_ENV" != 'prod' ]; then
    composer install
  fi;

fi

exec docker-php-entrypoint "$@"
