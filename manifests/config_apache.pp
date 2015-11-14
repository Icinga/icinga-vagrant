# == Class: graphite::config_apache
#
# This class configures apache to proxy requests to graphite web and SHOULD
# NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::config_apache inherits graphite::params {
  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  # we need an apache with python support

  package {
    $::graphite::params::apache_pkg:
      ensure => installed;
  }

  package {
    $::graphite::params::apache_wsgi_pkg:
      ensure  => installed,
      require => Package[$::graphite::params::apache_pkg]
  }

  case $::osfamily {
    'Debian': {
      # mod_header is disabled on Ubuntu by default,
      # but we need it for CORS headers
      if $::graphite::gr_web_cors_allow_from_all {
        exec { 'enable mod_headers':
          command => 'a2enmod headers',
          creates => '/etc/apache2/mods-enabled/headers.load',
          require => Package[$::graphite::params::apache_wsgi_pkg],
          notify  => Service[$::graphite::params::apache_service_name];
        }
      }

      exec { 'Disable default apache site':
        command => 'a2dissite 000-default',
        notify  => Service[$::graphite::params::apache_service_name],
        onlyif  => 'test -f /etc/apache2/sites-enabled/000-default -o -f /etc/apache2/sites-enabled/000-default.conf',
        require => Package[$::graphite::params::apache_wsgi_pkg],
      }
    }

    'RedHat': {
      file { "${::graphite::params::apacheconf_dir}/welcome.conf":
        ensure  => absent,
        notify  => Service[$::graphite::params::apache_service_name],
        require => Package[$::graphite::params::apache_wsgi_pkg],
      }
    }

    default: {
      fail("Module graphite is not supported on ${::operatingsystem}")
    }
  }

  service { $::graphite::params::apache_service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true;
  }

  # Deploy configfiles
  file {
    "${::graphite::params::apache_dir}/ports.conf":
      ensure  => file,
      content => template('graphite/etc/apache2/ports.conf.erb'),
      group   => $::graphite::params::web_group,
      mode    => '0644',
      owner   => $::graphite::params::web_user,
      require => [
        Exec['Initial django db creation'],
        Package[$::graphite::params::apache_wsgi_pkg],
      ],
      notify  => Service[$::graphite::params::apache_service_name];
    "${::graphite::params::apacheconf_dir}/graphite.conf":
      ensure  => file,
      content => template($::graphite::gr_apache_conf_template),
      group   => $::graphite::params::web_group,
      mode    => '0644',
      owner   => $::graphite::params::web_user,
      require => [
        File['/opt/graphite/storage'],
        File["${::graphite::params::apache_dir}/ports.conf"],
      ],
      notify  => Service[$::graphite::params::apache_service_name];
  }

  case $::osfamily {
    'Debian': {
      file { "/etc/apache2/sites-enabled/${::graphite::gr_apache_conf_prefix}graphite.conf":
        ensure  => link,
        notify  => Service[$::graphite::params::apache_service_name],
        require => File["${::graphite::params::apacheconf_dir}/graphite.conf"],
        target  => "${::graphite::params::apacheconf_dir}/graphite.conf",
      }
    }

    'RedHat': {
      if $::graphite::gr_apache_port != '80' {
        file { "${::graphite::params::apacheconf_dir}/${::graphite::params::apacheports_file}":
          ensure  => link,
          notify  => Service[$::graphite::params::apache_service_name],
          require => File["${::graphite::params::apache_dir}/ports.conf"],
          target  => "${::graphite::params::apache_dir}/ports.conf",
        }
      }
    }

    default: {}
  }
}
