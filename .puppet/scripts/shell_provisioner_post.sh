#!/bin/bash

set -e

if rpm -q "rh-php71-php-fpm" &>/dev/null; then
  systemctl restart rh-php71-php-fpm.service
fi

# workaround for https://github.com/Icinga/icinga2/issues/6112
systemctl restart icinga2
