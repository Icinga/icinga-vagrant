# == Class: icinga2::params
#
# In this class all default parameters are stored. It is inherited by other classes in order to get access to those
# parameters.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class is private and should not be called by others than this module.
#
#
class icinga2::params {

  $package          = 'icinga2'
  $service          = 'icinga2'
  $plugins          = [ 'plugins', 'plugins-contrib', 'windows-plugins', 'nscp' ]
  $default_features = [ 'checker', 'mainlog', 'notification' ]
  $globals          = [
    'Acknowledgement',
    'ApplicationType',
    'AttachDebugger',
    'BuildCompilerName',
    'BuildCompilerVersion',
    'BuildHostName',
    'Concurrency',
    'Critical',
    'Custom',
    'Deprecated',
    'Down',
    'DowntimeEnd',
    'DowntimeRemoved',
    'DowntimeStart',
    'FlappingEnd',
    'FlappingStart',
    'HostDown',
    'HostUp',
    'IncludeConfDir',
    'Internal',
    'Json',
    'LocalStateDir',
    'LogCritical',
    'LogDebug',
    'LogInformation',
    'LogNotice',
    'LogWarning',
    'Math',
    'ModAttrPath',
    'NodeName',
    'OK',
    'ObjectsPath',
    'PidPath',
    'PkgDataDir',
    'PlatformArchitecture',
    'PlatformKernel',
    'PlatformKernelVersion',
    'PlatformName',
    'PlatformVersion',
    'PrefixDir',
    'Problem',
    'Recovery',
    'RunAsGroup',
    'RunAsUser',
    'RunDir',
    'ServiceCritical',
    'ServiceOK',
    'ServiceUnknown',
    'ServiceWarning',
    'StatePath',
    'SysconfDir',
    'System',
    'Types',
    'Unknown',
    'Up',
    'UseVfork',
    'VarsPath',
    'Warning',
    'ZonesDir',
  ]

  case $::kernel {

    'linux': {
      $icinga2_bin          = 'icinga2'
      $conf_dir             = '/etc/icinga2'
      $log_dir              = '/var/log/icinga2'
      $run_dir              = '/var/run/icinga2'
      $spool_dir            = '/var/spool/icinga2'
      $cache_dir            = '/var/cache/icinga2'
      $pki_dir              = "${conf_dir}/pki"
      $ca_dir               = '/var/lib/icinga2/ca'
      $ido_pgsql_package    = 'icinga2-ido-pgsql'
      $ido_pgsql_schema_dir = '/usr/share/icinga2-ido-pgsql/schema'
      $ido_mysql_package    = 'icinga2-ido-mysql'
      $ido_mysql_schema_dir = '/usr/share/icinga2-ido-mysql/schema'
      $service_reload       = "service ${service} reload"

      case $::osfamily {
        'redhat': {
          $user    = 'icinga'
          $group   = 'icinga'
          $bin_dir = $::operatingsystemmajrelease ? {
            '5'     => '/usr/sbin',
            '6'     => '/usr/sbin',
            default => '/sbin',
          }
          $lib_dir = $::architecture ? {
            'x86_64' => '/usr/lib64',
            default  => '/usr/lib',
          }
        } # RedHat

        'debian': {
          $user    = 'nagios'
          $group   = 'nagios'
          $bin_dir = '/usr/sbin'
          $lib_dir = '/usr/lib'
        } # Debian

        'suse': {
          $user    = 'icinga'
          $group   = 'icinga'
          $bin_dir = '/usr/sbin'
          $lib_dir = '/usr/lib'
        } # Suse

        default: {
          fail("Your plattform ${::osfamily} is not supported, yet.")
        }
      } # case $::osfamily

      $constants = {
        'PluginDir'          => "${lib_dir}/nagios/plugins",
        'PluginContribDir'   => "${lib_dir}/nagios/plugins",
        'ManubulonPluginDir' => "${lib_dir}/nagios/plugins",
        'ZoneName'           => $::fqdn,
        'NodeName'           => $::fqdn,
        'TicketSalt'         => '',
      }
    } # Linux

    'windows': {
      $user                 = undef
      $group                = undef
      $icinga2_bin          = 'icinga2.exe'
      $bin_dir              = 'C:/Program Files/icinga2/sbin'
      $conf_dir             = 'C:/ProgramData/icinga2/etc/icinga2'
      $log_dir              = 'C:/ProgramData/icinga2/var/log/icinga2'
      $run_dir              = 'C:/ProgramData/icinga2/var/run/icinga2'
      $spool_dir            = 'C:/ProgramData/icinga2/var/spool/icinga2'
      $cache_dir            = 'C:/ProgramData/icinga2/var/cache/icinga2'
      $pki_dir              = "${conf_dir}/pki"
      $ca_dir               = 'C:/ProgramData/icinga2/var/lib/icinga2/ca'
      $ido_pgsql_package    = undef
      $ido_pgsql_schema_dir = undef
      $ido_mysql_package    = undef
      $ido_mysql_schema_dir = undef
      $service_reload       = undef

      $constants = {
        'PluginDir'          => 'C:/Program Files/ICINGA2/sbin',
        'PluginContribDir'   => 'C:/Program Files/ICINGA2/sbin',
        'ManubulonPluginDir' => 'C:/Program Files/ICINGA2/sbin',
        'ZoneName'           => $::fqdn,
        'NodeName'           => $::fqdn,
        'TicketSalt'         => '',
      }
    } # Windows

    'FreeBSD': {
      $bin_dir              = '/usr/local/sbin'
      $conf_dir             = '/usr/local/etc/icinga2'
      $log_dir              = '/var/log/icinga2'
      $run_dir              = '/var/run/icinga2'
      $spool_dir            = '/var/spool/icinga2'
      $cache_dir            = '/var/cache/icinga2'
      $pki_dir              = "${conf_dir}/pki"
      $ca_dir               = '/var/lib/icinga2/ca'
      $user                 = 'icinga'
      $group                = 'icinga'
      $icinga2_bin          = 'icinga2'
      $lib_dir              = '/usr/local/lib/icinga2'
      $ido_pgsql_package    = undef
      $ido_pgsql_schema_dir = '/usr/local/share/icinga2-ido-pgsql/schema'
      $ido_mysql_package    = undef
      $ido_mysql_schema_dir = '/usr/local/share/icinga2-ido-mysql/schema'
      $service_reload       = "service ${service} reload"

      $constants = {
        'PluginDir'          => '/usr/local/libexec/nagios',
        'PluginContribDir'   => '/usr/local/share/icinga2/include/plugins-contrib.d',
        'ManubulonPluginDir' => '/usr/local/libexec/nagios',
        'ZoneName'           => $::fqdn,
        'NodeName'           => $::fqdn,
        'TicketSalt'         => '',
      }
    } # FreeBSD

    default: {
      fail("Your plattform ${::osfamily} is not supported, yet.")
    }

  } # case $::kernel

}
