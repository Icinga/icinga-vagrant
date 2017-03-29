# Class: kibana::install
#
# This class is called from the ::kibana class to manage installation.
#
class kibana::install {

  if $::kibana::manage_repo {
    $_ensure = $::kibana::ensure ? {
      'absent' => $::kibana::ensure,
      default  => 'present',
    }

    if $::kibana::repo_version =~ /^4[.]/ {
      $_repo_baseurl = "https://packages.elastic.co/kibana/${::kibana::repo_version}"
      $_repo_path = $::osfamily ? {
        'Debian'          => 'debian',
        /(RedHat|Amazon)/ => 'centos'
      }
    } else {
      $_repo_baseurl = "https://artifacts.elastic.co/packages/${::kibana::repo_version}"
      $_repo_path = $::osfamily ? {
        'Debian'          => 'apt',
        /(RedHat|Amazon)/ => 'yum'
      }
    }

    case $::osfamily {
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
        } ~>
        exec { 'kibana_yumrepo_yum_clean':
          command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="kibana"',
          path        => [ '/bin', '/usr/bin' ],
          refreshonly => true,
          returns     => [0, 1],
          before      => Package['kibana'],
        }
      }
      default: {
        fail("unsupported operating system family ${::osfamily}")
      }
    }
  }

  package { 'kibana':
    ensure => $::kibana::ensure,
  }
}
