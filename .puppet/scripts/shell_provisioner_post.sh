#!/bin/bash

set -e

if rpm -q "rh-php71-php-fpm" &>/dev/null; then
  systemctl restart rh-php71-php-fpm.service
fi

# workaround for icingacli and users
if getent group icingaweb2; then
  usermod -a -G icingaweb2 icinga && systemctl restart icinga2
fi

