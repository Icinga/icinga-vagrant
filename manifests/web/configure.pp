# == Class: graylog2::web::configure
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::configure (
  $config_file,
  $daemon_username,
  $graylog2_server_uris,
  $application_secret,
  $command_wrapper,
  $timezone = undef,
  $field_list_limit,
  $http_address,
  $http_port,
  $http_path_prefix,
  $timeout,
) {

  validate_array(
    $graylog2_server_uris,
  )

  validate_string(
    $daemon_username,
    $application_secret,
    $command_wrapper,
    $field_list_limit,
    $http_address,
    $http_port,
  )

  validate_absolute_path(
    $config_file,
  )

  # This is required and there is no default!
  if ! $application_secret {
    fail('Missing or empty application_secret parameter!')
  }

  if size($application_secret) < 64 {
    fail('The application_secret parameter is too short. (at least 64 characters)!')
  }

  ensure_resource('file', '/etc/graylog/web', {
    ensure  => directory,
    owner   => $daemon_username,
    group   => $daemon_username,
  })

  case $::osfamily {
    'Debian': {
      file { '/etc/default/graylog-web':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/web.default.erb"),
      }
    }
    'RedHat': {
      file { '/etc/sysconfig/graylog-web':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/web.sysconfig.erb"),
      }
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  file {$config_file:
    ensure    => file,
    owner     => $daemon_username,
    group     => $daemon_username,
    mode      => '0640',
    show_diff => false,
    content   => template("${module_name}/web.conf.erb"),
  }

}
