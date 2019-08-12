# @summary
#   Manage the Net-SNMP client package and configuration.
#
# @example
#   class { 'snmp::client':
#     snmp_config => [
#       'defVersion 2c',
#       'defCommunity public',
#     ],
#   }
#
# @param ensure
#   Ensure if present or absent.
#
# @param snmp_config
#   Array of lines to add to the client's global snmp.conf file.
#   See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
#
# @param autoupgrade
#   Upgrade package automatically, if there is a newer version.
#
# @param package_name
#   Name of the package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#
# @param client_config
#   Path to `snmp.conf`.
#
class snmp::client (
  Enum['present', 'absent']  $ensure        = 'present',
  Optional[Array[String[1]]] $snmp_config   = undef,
  Boolean                    $autoupgrade   = false,
  Optional[String[1]]        $package_name  = undef,
  Stdlib::Absolutepath       $client_config = '/etc/snmp/snmp.conf',
) {

  include snmp

  if $ensure == 'present' {
    if $autoupgrade {
      $package_ensure = 'latest'
    } else {
      $package_ensure = 'present'
    }
    $file_ensure = 'present'
  } else {
    $package_ensure = 'absent'
    $file_ensure = 'absent'
  }

  if ($package_name) and ($package_name != $snmp::package_name) {
    package { 'snmp-client':
      ensure => $package_ensure,
      name   => $package_name,
      before => File['snmp.conf'],
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    file { '/etc/snmp':
      ensure => directory,
    }
  }

  file { 'snmp.conf':
    ensure  => $file_ensure,
    path    => $client_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('snmp/snmp.conf.erb'),
  }
}
