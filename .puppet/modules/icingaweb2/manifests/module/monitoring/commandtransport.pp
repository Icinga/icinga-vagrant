# == Define: icingaweb2::module::monitoring::commandtransport
#
# Manage commandtransport configuration for the monitoring module
#
# === Parameters
#
# [*commandtransport*]
#   The name of the commandtransport.
#
# [*transport*]
#   The transport type you wish to use. Either `api` or `local`. Defaults to `api`
#
# [*host*]
#   Hostname/ip for the transport. Only needed for api transport. Defaults to `localhost`
#
# [*port*]
#   Port for the transport. Only needed for api transport. Defaults to `5665`
#
# [*username*]
#   Username for the transport. Only needed for api transport.
#
# [*password*]
#   Password for the transport. Only needed for api transport.
#
# [*path*]
#   Path for the transport. Only needed for local transport. Defaults to `/var/run/icinga2/cmd/icinga2.cmd`
#
define icingaweb2::module::monitoring::commandtransport(
  String               $commandtransport = $title,
  Enum['api', 'local'] $transport        = 'api',
  String               $host             = 'localhost',
  Integer[1,65535]     $port             = 5665,
  Optional[String]     $username         = undef,
  Optional[String]     $password         = undef,
  Stdlib::Absolutepath $path             = '/var/run/icinga2/cmd/icinga2.cmd',
){
  assert_private("You're not supposed to use this defined type manually.")

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/monitoring"

  case $transport {
    'api': {
      $commandtransport_settings = {
        'transport' => $transport,
        'host'      => $host,
        'port'      => $port,
        'username'  => $username,
        'password'  => $password,
      }
    }
    'local': {
      $commandtransport_settings = {
        'transport' => $transport,
        'path'      => $path,
      }
    }
    default: {
      fail('The transport type you provided is not supported')
    }
  }

  icingaweb2::inisection { "monitoring-commandtransport-${commandtransport}":
    section_name => $commandtransport,
    target       => "${module_conf_dir}/commandtransports.ini",
    settings     => delete_undef_values($commandtransport_settings),
  }
}
