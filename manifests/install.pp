# == Class grafana::install
#
class grafana::install {
  if $::grafana::archive_source != undef {
    $real_archive_source = $::grafana::archive_source
  }
  else {
    $real_archive_source = "https://grafanarel.s3.amazonaws.com/builds/grafana-${::grafana::version}.linux-x64.tar.gz"
  }

  if $::grafana::package_source != undef {
    $real_package_source = $::grafana::package_source
  }
  else {
    $real_package_source = $::osfamily ? {
      /(RedHat|Amazon)/ => "https://grafanarel.s3.amazonaws.com/builds/grafana-${::grafana::version}-${::grafana::rpm_iteration}.x86_64.rpm",
      'Debian'          => "https://grafanarel.s3.amazonaws.com/builds/grafana_${::grafana::version}_amd64.deb",
      default           => $real_archive_source,
    }
  }
  
  case $::grafana::install_method {
    'docker': {
      docker::image { 'grafana/grafana':
        image_tag => $::grafana::version,
        require   => Class['docker']
      }
    }
    'package': {
      case $::osfamily {
        'Debian': {
          package { 'libfontconfig1':
            ensure => present
          }

          wget::fetch { 'grafana':
            source      => $real_package_source,
            destination => '/tmp/grafana.deb'
          }

          package { $::grafana::package_name:
            ensure   => present,
            provider => 'dpkg',
            source   => '/tmp/grafana.deb',
            require  => [Wget::Fetch['grafana'],Package['libfontconfig1']]
          }
        }
        'RedHat': {
          package { 'fontconfig':
            ensure => present
          }

          package { $::grafana::package_name:
            ensure   => present,
            provider => 'rpm',
            source   => $real_package_source,
            require  => Package['fontconfig']
          }
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
    'repo': {
      case $::osfamily {
        'Debian': {
          package { 'libfontconfig1':
            ensure => present
          }

          if ( $::grafana::manage_package_repo ){
            if !defined( Class['apt'] ) {
              class { 'apt': }
            }
            apt::source { 'grafana':
              location => "https://packagecloud.io/grafana/${::grafana::repo_name}/debian",
              release  => 'wheezy',
              repos    => 'main',
              key      =>  {
                'id'     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
                'source' => 'https://packagecloud.io/gpg.key'
              },
              before   => Package[$::grafana::package_name],
            }
            Class['apt::update'] -> Package[$::grafana::package_name]
          }

          package { $::grafana::package_name:
            ensure  => $::grafana::version,
            require => Package['libfontconfig1']
          }
        }
        'RedHat': {
          package { 'fontconfig':
            ensure => present
          }

          if ( $::grafana::manage_package_repo ){
            yumrepo { 'grafana':
              descr    => 'grafana repo',
              baseurl  => 'https://packagecloud.io/grafana/stable/el/6/$basearch',
              gpgcheck => 1,
              gpgkey   => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
              enabled  => 1,
              before   => Package[$::grafana::package_name],
            }
          }

          package { $::grafana::package_name:
            ensure  => "${::grafana::version}-${::grafana::rpm_iteration}",
            require => Package['fontconfig']
          }
        }
        default: {
          fail("${::operatingsystem} not supported")
        }
      }
    }
    'archive': {
      # create log directory /var/log/grafana (or parameterize)

      if !defined(User['grafana']){
        user { 'grafana':
          ensure => present,
          home   => $::grafana::install_dir
        }
      }

      file { $::grafana::install_dir:
        ensure  => directory,
        group   => 'grafana',
        owner   => 'grafana',
        require => User['grafana']
      }

      archive { '/tmp/grafana.tar.gz':
        ensure          => present,
        extract         => true,
        extract_command => 'tar xfz %s --strip-components=1',
        extract_path    => $::grafana::install_dir,
        source          => $real_archive_source,
        user            => 'grafana',
        group           => 'grafana',
        cleanup         => true,
        require         => File[$::grafana::install_dir]
      }

    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }
}
