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

      if ($::graphite::gr_web_server_port == 80 and $::graphite::gr_web_server_remove_default == undef) or ($::graphite::gr_web_server_remove_default == true) {
        exec { 'Disable default apache site':
          command => 'a2dissite 000-default',
          notify  => Service[$::graphite::params::apache_service_name],
          onlyif  => 'test -f /etc/apache2/sites-enabled/000-default -o -f /etc/apache2/sites-enabled/000-default.conf',
          require => Package[$::graphite::params::apache_wsgi_pkg],
        }
      }
    }

    'RedHat': {
      if ($::graphite::gr_web_server_port == 80 and $::graphite::gr_web_server_remove_default == undef) or ($::graphite::gr_web_server_remove_default == true) {
        file { "${::graphite::params::apacheconf_dir}/welcome.conf":
          ensure  => absent,
          notify  => Service[$::graphite::params::apache_service_name],
          require => Package[$::graphite::params::apache_wsgi_pkg],
        }
      }
    }

    default: {
      fail("Module graphite is not supported on ${::operatingsystem}")
    }
  }

  # Create the log dir if it doesn't exist
  file { $::graphite::gr_apache_logdir:
    ensure  => directory,
    group   => $::graphite::config::gr_web_group_REAL,
    mode    => '0644',
    owner   => $::graphite::config::gr_web_user_REAL,
    require => Package[$::graphite::params::apache_pkg],
    before  => Service[$::graphite::params::apache_service_name]
  }

  # fix graphite's race condition on start
  # if the exec fails, assume we're using a version of graphite that doesn't need it
  file { '/tmp/fix-graphite-race-condition.py':
    ensure => file,
    source => 'puppet:///modules/graphite/fix-graphite-race-condition.py',
    mode   => '0755',
  }
  exec { 'fix graphite race condition':
    command     => "${::graphite::gr_python_binary} /tmp/fix-graphite-race-condition.py",
    cwd         => $graphite::graphiteweb_webapp_dir_REAL,
    environment => 'DJANGO_SETTINGS_MODULE=graphite.settings',
    user        => $graphite::config::gr_web_user_REAL,
    logoutput   => true,
    group       => $graphite::config::gr_web_group_REAL,
    returns     => [0, 1],
    refreshonly => true,
    require     => [
      File['/tmp/fix-graphite-race-condition.py'],
      File[$::graphite::storage_dir_REAL],
      File[$::graphite::graphiteweb_log_dir_REAL],
      File[$::graphite::graphiteweb_storage_dir_REAL],
      File["${::graphite::storage_dir_REAL}/graphite.db"],
    ],
    before      => Service[$::graphite::params::apache_service_name],
    subscribe   => Exec['Initial django db creation'],
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
      group   => $::graphite::config::gr_web_group_REAL,
      mode    => '0644',
      owner   => $::graphite::config::gr_web_user_REAL,
      require => [
        Exec['Initial django db creation'],
        Package[$::graphite::params::apache_wsgi_pkg],
      ],
      notify  => Service[$::graphite::params::apache_service_name];

    "${::graphite::params::apacheconf_dir}/graphite.conf":
      ensure  => file,
      content => template($::graphite::gr_apache_conf_template),
      group   => $::graphite::config::gr_web_group_REAL,
      mode    => '0644',
      owner   => $::graphite::config::gr_web_user_REAL,
      require => [
        File[$::graphite::storage_dir_REAL],
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
      if $::graphite::gr_web_server_port != 80 {
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
