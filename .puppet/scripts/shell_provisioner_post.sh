#!/bin/bash

set -e

if rpm -q "rh-php71-php-fpm" &>/dev/null; then
  systemctl restart rh-php71-php-fpm.service
fi
