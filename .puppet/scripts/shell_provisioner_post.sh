#!/bin/bash

set -e

if rpm -q "rh-php73-php-fpm" &>/dev/null; then
  systemctl restart rh-php73-php-fpm.service
fi
