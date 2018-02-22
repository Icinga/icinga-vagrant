# == Class: icinga2::repo
#
# This class manages the packages.icinga.com repository based on the operating system. Windows is not supported, as the
# Icinga Project does not offer a chocolate repository.
#
# === Parameters
#
# This class does not provide any parameters.
# To control the behaviour of this class, have a look at the parameters:
# * icinga2::manage_repo
#
# === Examples
#
# This class is private and should not be called by others than this module.
#
#
class icinga2::repo {

  assert_private()

  if $::icinga2::manage_repo and $::icinga2::manage_package {

    case $::osfamily {
      'redhat': {
        case $::operatingsystem {
          'centos', 'redhat', 'oraclelinux': {
            yumrepo { 'icinga-stable-release':
              baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/release/",
              descr    => 'ICINGA (stable release for epel)',
              enabled  => 1,
              gpgcheck => 1,
              gpgkey   => 'http://packages.icinga.com/icinga.key',
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
      }
      'debian': {
        # handle icinga stable repo before all package resources
        # contain class problem!
        Apt::Source['icinga-stable-release'] -> Package <| tag == 'icinga2' |>
        case $::operatingsystem {
          'debian': {
            include ::apt, ::apt::backports
            apt::source { 'icinga-stable-release':
              location => 'http://packages.icinga.com/debian',
              release  => "icinga-${::lsbdistcodename}",
              repos    => 'main',
              key      => {
                id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
                source => 'http://packages.icinga.com/icinga.key',
              },
              require  => Class['::apt::backports'],
            }
          }
          'ubuntu': {
            include ::apt
            apt::source { 'icinga-stable-release':
              location => 'http://packages.icinga.com/ubuntu',
              release  => "icinga-${::lsbdistcodename}",
              repos    => 'main',
              key      => {
                id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
                source => 'http://packages.icinga.com/icinga.key',
              };
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
        contain ::apt::update
      }
      'suse': {

        file { '/etc/pki/GPG-KEY-icinga':
          ensure => present,
          source => 'http://packages.icinga.com/icinga.key',
        }

        exec { 'import icinga gpg key':
          path      => '/bin:/usr/bin:/sbin:/usr/sbin',
          command   => 'rpm --import /etc/pki/GPG-KEY-icinga',
          unless    => "rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < /etc/pki/GPG-KEY-icinga) | cut --characters=11-18 | tr [A-Z] [a-z]`",
          require   => File['/etc/pki/GPG-KEY-icinga'],
          logoutput => 'on_failure',
        }

        case $::operatingsystem {
          'SLES': {
            zypprepo { 'icinga-stable-release':
              baseurl  => "http://packages.icinga.com/SUSE/${::operatingsystemrelease}/release/",
              enabled  => 1,
              gpgcheck => 1,
              require  => Exec['import icinga gpg key']
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
      }
      'windows': {
        warning("The Icinga Project doesn't offer chocolaty packages at the moment.")
      }
      default: {
        fail('Your plattform is not supported to manage a repository.')
      }
    }

  } # if $::icinga::manage_repo

}
