# == Class prometheus::service
#
# This class is meant to be called from prometheus
# It ensure the service is running
#
class prometheus::run_service {

  $init_selector = $prometheus::server::init_style ? {
    'launchd' => 'io.prometheus.daemon',
    default   => 'prometheus',
  }

  if $prometheus::server::manage_service == true {
    service { 'prometheus':
      ensure => $prometheus::server::service_ensure,
      name   => $init_selector,
      enable => $prometheus::server::service_enable,
    }
  }
}
