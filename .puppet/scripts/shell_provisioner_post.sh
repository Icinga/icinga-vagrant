#!/bin/bash

set -e

if rpm -q "rh-php71-php-fpm" &>/dev/null; then
  systemctl restart rh-php71-php-fpm.service
fi

if rpm -q "icinga2-bin" &>/dev/null; then
  # workaround for https://github.com/Icinga/icinga2/issues/6112
  systemctl restart icinga2
fi
