# This module manages timezone settings
#
# @param timezone
#     The name of the timezone.
#
# @param ensure
#     Ensure if present or absent.
#
# @param autoupgrade
#     Upgrade package automatically, if there is a newer version.
#
# @param package
#     Name of the package.
#     Only set this, if your platform is not supported or you know, what you're doing.
#
# @param config_file
#     Main configuration file.
#     Only set this, if your platform is not supported or you know, what you're doing.
#
# @param zoneinfo_dir
#     Source directory of zoneinfo files.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
# @param hwutc
#     Is the hardware clock set to UTC? (true or false)
#
# @param notify_services
#     List of services to notify
#
# @example
#   class { 'timezone':
#     timezone => 'Europe/Berlin',
#   }
#
class timezone (
  String                   $timezone                       = 'Etc/UTC',
  Enum['present','absent'] $ensure                         = 'present',
  Optional[Boolean]        $hwutc                          = undef,
  Boolean                  $autoupgrade                    = false,
  Optional[Array[String]]  $notify_services                = undef,
  Optional[String]         $package                        = undef,
  String                   $zoneinfo_dir                   = '/usr/share/zoneinfo/',
  String                   $localtime_file                 = '/etc/localtime',
  Optional[String]         $timezone_file                  = undef,
  Optional[String]         $timezone_file_template         = 'timezone/clock.erb',
  Optional[Boolean]        $timezone_file_supports_comment = undef,
  Optional[String]         $timezone_update                = undef
) {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      $localtime_ensure = 'link'
      $timezone_ensure = 'file'
    }
    /(absent)/: {
      # Leave package installed, as it is a system dependency
      $package_ensure = 'present'
      $localtime_ensure = 'absent'
      $timezone_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  if $package {
    $use_debconf = lookup('timezone::use_debconf', Boolean, 'first', false)
    if $package_ensure == 'present' and $use_debconf {
      $_tz = split($timezone, '/')
      $area = $_tz[0]
      $zone = $_tz[1]

      debconf {
        'tzdata/Areas':
          package => 'tzdata',
          item    => 'tzdata/Areas',
          type    => 'select',
          value   => $area;
        "tzdata/Zones/${area}":
          package => 'tzdata',
          item    => "tzdata/Zones/${area}",
          type    => 'select',
          value   => $zone;
      }
      -> Package[$package]
    }

    package { $package:
      ensure => $package_ensure,
      before => File[$localtime_file],
    }
  }

  file { $localtime_file:
    ensure => $localtime_ensure,
    target => "${zoneinfo_dir}/${timezone}",
    force  => true,
    notify => $notify_services,
  }

  if $timezone_file {
    file { $timezone_file:
      ensure  => $timezone_ensure,
      content => template($timezone_file_template),
      notify  => $notify_services,
    }

    if $ensure == 'present' and $timezone_update {
      exec { 'update_timezone':
        command     => sprintf($timezone_update, $timezone),
        subscribe   => File[$timezone_file],
        refreshonly => true,
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        require     => File[$localtime_file],
      }
    }
  } else {
    if $ensure == 'present' and $timezone_update {
      $unless_cmd = lookup('timezone::timezone_update_check_cmd', String, 'first')
      exec { 'update_timezone':
        command => sprintf($timezone_update, $timezone),
        unless  => sprintf($unless_cmd, $timezone),
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        require => File[$localtime_file],
      }
    }
  }

  if $ensure == 'present' and $hwutc != undef {
    $hwclock_cmd = lookup('timezone::hwclock_cmd', Optional[String], 'first', undef)
    $hwclock_check_enabled_cmd = lookup('timezone::check_hwclock_enabled_cmd', Optional[String], 'first', undef)
    $hwclock_check_disabled_cmd = lookup('timezone::check_hwclock_disabled_cmd', Optional[String], 'first', undef)

    if $hwclock_cmd != '' and $hwclock_cmd != undef {
      if ! $hwutc {
        $hwclock_unless = $hwclock_check_enabled_cmd
      } else {
        $hwclock_unless = $hwclock_check_disabled_cmd
      }
      exec { 'set_hwclock':
        command => sprintf($hwclock_cmd, (! $hwutc)),
        unless  => $hwclock_unless,
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      }
    }
  }

}
