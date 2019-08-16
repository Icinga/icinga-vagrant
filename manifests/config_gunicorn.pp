# == Class: graphite::config_gunicorn
#
# This class configures graphite/carbon/whisper and SHOULD NOT be
# called directly.
#
# === Parameters
#
# None.
#
class graphite::config_gunicorn inherits graphite::params {
  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  case $::osfamily {

    'Debian': {
      $package_name = 'gunicorn'

      # Debian has a wrapper script called `gunicorn-debian` for multiple gunicorn
      # configs. Each config is stored as a separate file in /etc/gunicorn.d/.
      # On debian 8 and Ubuntu 15.10, which use systemd, the gunicorn-debian
      # config file has to be installed before the gunicorn package.
      # TODO: special cases for deb 8 and ubuntu 15.10
      file { '/etc/gunicorn.d':
        ensure => directory,
      }
      file { '/etc/gunicorn.d/graphite':
        ensure  => file,
        content => template('graphite/etc/gunicorn.d/graphite.erb'),
        mode    => '0644',
        before  => Package[$package_name],
        require => File['/etc/gunicorn.d'],
      }
    }

    'RedHat': {
      $package_name = 'python-gunicorn'

      # RedHat package is missing initscript
      # RedHat 7+ uses systemd
      if $::graphite::gr_service_provider == 'redhat' {
        file { '/etc/init.d/gunicorn':
          ensure  => file,
          content => template('graphite/etc/init.d/RedHat/gunicorn.erb'),
          mode    => '0755',
          before  => Service['gunicorn'],
        }
      }

    }

    default: {
      fail("wsgi/gunicorn-based graphite is not supported on ${::operatingsystem} (only supported on Debian & RedHat)")
    }

  }

  if $::graphite::gr_service_provider == 'systemd' {
    file { '/etc/systemd/system/gunicorn.service':
      ensure  => file,
      content => template('graphite/etc/systemd/gunicorn.service.erb'),
      mode    => '0644',
    }

    file { '/etc/systemd/system/gunicorn.socket':
      ensure  => file,
      content => template('graphite/etc/systemd/gunicorn.socket.erb'),
      mode    => '0755',
    }

    file { '/etc/tmpfiles.d/gunicorn.conf':
      ensure  => file,
      content => template('graphite/etc/tmpfiles.d/gunicorn.conf.erb'),
      mode    => '0644',
    }

    # TODO: we should use the exec graphite-reload-systemd from config class
    exec { 'gunicorn-reload-systemd':
      command     => 'systemctl daemon-reload',
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      refreshonly => true,
      subscribe   => [
        File['/etc/systemd/system/gunicorn.service'],
        File['/etc/systemd/system/gunicorn.socket'],
        File['/etc/tmpfiles.d/gunicorn.conf'],
      ],
      before      => Service['gunicorn'],
    }
  }

  # fix graphite's race condition on start
  # if the exec fails, assume we're using a version of graphite that doesn't need it
  if $graphite::gunicorn_workers > 1 {
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
      ],
      before      => Package[$package_name],
      subscribe   => Exec['Initial django db creation'],
    }
  }

  # Only install gunicorn after graphite is ready to go
  package {
    $package_name:
      ensure  => installed,
      require => [
        File[$graphite::storage_dir_REAL],
        File[$graphite::graphiteweb_log_dir_REAL],
        Exec['Initial django db creation'],
      ];
  }

  service { 'gunicorn':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    provider   => $::graphite::gr_service_provider,
    require    => [
      Package[$package_name],
      File["${::graphite::graphiteweb_conf_dir_REAL}/graphite_wsgi.py"]
    ],
  }

}
