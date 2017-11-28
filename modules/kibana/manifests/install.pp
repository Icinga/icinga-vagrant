# This class is called from the kibana class to manage installation.
# It is not meant to be called directly.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class kibana::install {

  if $::kibana::manage_repo {
    $_ensure = $::kibana::ensure ? {
      'absent' => $::kibana::ensure,
      default  => 'present',
    }

    if $::kibana::repo_version =~ /^4[.]/ {
      $_repo_baseurl = "https://packages.elastic.co/kibana/${::kibana::repo_version}"
      $_repo_path = $facts['os']['family'] ? {
        'Debian'          => 'debian',
        /(RedHat|Amazon)/ => 'centos'
      }
    } else {
      $_repo_baseurl = "https://artifacts.elastic.co/packages/${::kibana::repo_version}"
      $_repo_path = $facts['os']['family'] ? {
        'Debian'          => 'apt',
        /(RedHat|Amazon)/ => 'yum'
      }
    }

    case $facts['os']['family'] {
      'Debian': {
        include ::apt
        Class['apt::update'] -> Package['kibana']

        apt::source { 'kibana':
          ensure   => $_ensure,
          location => "${_repo_baseurl}/${_repo_path}",
          release  => 'stable',
          repos    => 'main',
          key      => {
            'id'     => $::kibana::repo_key_id,
            'source' => $::kibana::repo_key_source,
          },
          include  => {
            'src' => false,
            'deb' => true,
          },
          pin      => $::kibana::repo_priority,
          before   => Package['kibana'],
        }
      }
      'RedHat', 'Amazon': {
        yumrepo { 'kibana':
          ensure   => $_ensure,
          descr    => "Elastic ${::kibana::repo_version} repository",
          baseurl  => "${_repo_baseurl}/${_repo_path}",
          gpgcheck => 1,
          gpgkey   => $::kibana::repo_key_source,
          enabled  => 1,
          proxy    => $::kibana::repo_proxy,
          priority => $::kibana::repo_priority,
          before   => Package['kibana'],
        }
        ~> exec { 'kibana_yumrepo_yum_clean':
          command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="kibana"',
          path        => [ '/bin', '/usr/bin' ],
          refreshonly => true,
          returns     => [0, 1],
          before      => Package['kibana'],
        }
      }
      default: {
        fail("unsupported operating system family ${facts['os']['family']}")
      }
    }
  }

  if $::kibana::package_source != undef {
    case $facts['os']['family'] {
      'Debian': { Package['kibana'] { provider => 'dpkg' } }
      'RedHat': { Package['kibana'] { provider => 'rpm' } }
      default: { fail("unsupported parameter 'source' set for osfamily ${facts['os']['family']}") }
    }
  }

  package { 'kibana':
    ensure => $::kibana::ensure,
    source => $::kibana::package_source,
  }
}
