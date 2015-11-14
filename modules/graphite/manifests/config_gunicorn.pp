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

  if $::osfamily == 'Debian' {

    package {
      'gunicorn':
        ensure => installed;
    }

    service { 'gunicorn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      require    => [
        File['/opt/graphite/storage/run'],
        File['/opt/graphite/storage/log'],
        Exec['Initial django db creation'],
        Package['gunicorn'],
      ],
      subscribe  => File['/opt/graphite/webapp/graphite/local_settings.py'],
    }

    # Deploy configfiles

    file { '/etc/gunicorn.d/graphite':
      ensure  => file,
      content => template('graphite/etc/gunicorn.d/graphite.erb'),
      mode    => '0644',
      notify  => Service['gunicorn'],
      require => Package['gunicorn'],
    }
  } elsif $::osfamily == 'RedHat' {

    package {
      'python-gunicorn':
        ensure => installed;
    }
  } else {
    fail("wsgi/gunicorn-based graphite is not supported on ${::operatingsystem} (only supported on Debian & RedHat)")
  }
}
