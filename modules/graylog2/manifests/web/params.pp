# == Class: graylog2::web::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::web::params {

  # OS specific settings.
  case $::osfamily {
    'Debian', 'RedHat': {
      # Nothing yet.
    }
    default: {
      fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  $package_name = 'graylog-web'

  $package_version = 'installed'

  $service_name  = 'graylog-web'

  $service_ensure = 'running'

  $service_enable = true

  $graylog2_server_uris = ['http://127.0.0.1:12900/']

  $application_secret = undef

  $command_wrapper = ''

  $timezone = undef

  $field_list_limit = '100'

  $http_address = '0.0.0.0'

  $http_port = '9000'

  $http_path_prefix = false

  $config_file = '/etc/graylog/web/web.conf'

  $daemon_username = 'graylog-web'

  $timeout = false

}
