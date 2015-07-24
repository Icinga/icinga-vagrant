# == Class: graylog2::radio::service
#
# === Authors
#
# Renan Silva <renanvice@gmail.com>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::radio::service (
  $service_name,
  $service_ensure,
  $service_enable,
) {

  $service_provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  if $service_provider {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
      provider   => $service_provider,
    }
  } else {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
