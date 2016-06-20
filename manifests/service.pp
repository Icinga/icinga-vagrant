# == Class grafana::service
#
# This class is meant to be called from grafana
# It ensure the service is running
#
class grafana::service {
  case $::grafana::install_method {
    'docker': {
      $container = {
        'grafana' => $::grafana::container_params
      }

      $defaults = {
        image => "${::grafana::params::docker_image}:${::grafana::version}",
        ports => $::grafana::params::docker_ports
      }

      create_resources(docker::run, $container, $defaults)
    }
    'package','repo': {
      service { $::grafana::service_name:
        ensure    => running,
        enable    => true,
        subscribe => Package[$::grafana::package_name]
      }
    }
    'archive': {
      $service_path   = "${::grafana::install_dir}/bin/${::grafana::service_name}"
      $service_config = "${::grafana::install_dir}/conf/custom.ini"

      if !defined(Service[$::grafana::service_name]){
        service { $::grafana::service_name:
          ensure     => running,
          provider   => base,
          binary     => "su - grafana -c '${service_path} -config=${service_config} -homepath=${::grafana::install_dir} web &'",
          hasrestart => false,
          hasstatus  => false,
          status     => "ps -ef | grep ${::grafana::service_name} | grep -v grep"
        }
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
