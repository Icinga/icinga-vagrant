# == Define: icinga2::config::fragment
#
# Set a code fragment in a target configuration file.
#
# === Parameters
#
# [*content*]
#   Content to insert in file specified in target.
#
# [*target*]
#   Destination config file to store in this fragment. File will be declared the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted in alpha numeric order.
#
#
define icinga2::config::fragment(
  $content,
  $target,
  $code_name = $title,
  $order     = '0',
) {

  include ::icinga2::params
  require ::icinga2::config

  case $::osfamily {
    'windows': {
      Concat {
        owner => 'Administrators',
        group => 'NETWORK SERVICE',
        mode  => '0770',
      }
      $_content = regsubst($content, '\n', "\r\n", 'EMG')
    } # windows
    default: {
      Concat {
        owner => $::icinga2::params::user,
        group => $::icinga2::params::group,
        mode  => '0640',
      }
      $_content = $content
    } # default
  }

  validate_string($content)
  validate_absolute_path($target)
  validate_string($order)

  if !defined(Concat[$target]) {
    concat { $target:
      ensure => present,
      tag    => 'icinga2::config::file',
      warn   => true,
    }
  }

  concat::fragment { "icinga2::config::${code_name}":
    target  => $target,
    content => $_content,
    order   => $order,
    notify  => Class['::icinga2::service'],
  }

}
