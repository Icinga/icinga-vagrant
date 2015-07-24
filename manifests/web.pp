# == Class: graylog2::web
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web (
  $package_version      = $graylog2::web::params::package_version,
  $service_ensure       = $graylog2::web::params::service_ensure,
  $service_enable       = $graylog2::web::params::service_enable,
  $graylog2_server_uris = $graylog2::web::params::graylog2_server_uris,
  $application_secret   = $graylog2::web::params::application_secret,
  $command_wrapper      = $graylog2::web::params::command_wrapper,
  $timezone             = $graylog2::web::params::timezone,
  $field_list_limit     = $graylog2::web::params::field_list_limit,
  $http_address         = $graylog2::web::params::http_address,
  $http_port            = $graylog2::web::params::http_port,
  $http_path_prefix     = $graylog2::web::params::http_path_prefix,
  $config_file          = $graylog2::web::params::config_file,
  $daemon_username      = $graylog2::web::params::daemon_username,
  $timeout              = $graylog2::web::params::timeout,

) inherits graylog2::web::params {

  anchor {'graylog2::web::start': }->
  class {'graylog2::web::package':
    package => $graylog2::web::params::package_name,
    version => $package_version,
  } ->
  class {'graylog2::web::configure':
    graylog2_server_uris => $graylog2_server_uris,
    application_secret   => $application_secret,
    command_wrapper      => $command_wrapper,
    timezone             => $timezone,
    field_list_limit     => $field_list_limit,
    http_address         => $http_address,
    http_port            => $http_port,
    http_path_prefix     => $http_path_prefix,
    config_file          => $config_file,
    daemon_username      => $daemon_username,
    timeout              => $timeout,
  } ~>
  class {'graylog2::web::service':
    service_name   => $graylog2::web::params::service_name,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  } ->
  anchor {'graylog2::web::end': }

}
