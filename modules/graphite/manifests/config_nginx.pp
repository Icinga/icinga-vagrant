# == Class: graphite::config_nginx
#
# This class configures nginx to talk to graphite/carbon/whisper and SHOULD
# NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::config_nginx inherits graphite::params {
  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  # we need a nginx with gunicorn for python support

  package {
    'nginx':
      ensure => installed;
  }

  # Ensure that some directories exist first. This is normally handled by the
  # package, but if we uninstall and reinstall nginx and delete /etc/nginx.
  # By default the package manager won't replace the directory.
  file {
    '/etc/nginx':
      ensure  => directory,
      mode    => '0755',
      require => Package['nginx'];
  }

  # Remove default config file, but only when it makes sense
  case $::osfamily {
    'Debian': {

      # Ensure that some directories exist first. This is normally handled by the
      # package, but if we uninstall and reinstall nginx and delete /etc/nginx.
      # By default the package manager won't replace the directory.
      file {
        '/etc/nginx/sites-available':
          ensure  => directory,
          mode    => '0755',
          require => File['/etc/nginx'];

        '/etc/nginx/sites-enabled':
          ensure  => directory,
          mode    => '0755',
          require => File['/etc/nginx'];
      }

      # Deploy configfiles
      file {
        '/etc/nginx/sites-available/graphite':
          ensure  => file,
          mode    => '0644',
          content => template('graphite/etc/nginx/sites-available/graphite.erb'),
          require => [
            File['/etc/nginx/sites-available'],
            Exec['Initial django db creation']
          ],
          notify  => Service['nginx'];

        '/etc/nginx/sites-enabled/graphite':
          ensure  => link,
          target  => '/etc/nginx/sites-available/graphite',
          require => [
            File['/etc/nginx/sites-available/graphite'],
            File['/etc/nginx/sites-enabled']
          ],
          notify  => Service['nginx'];
      }

      # Remove default config file, but only when it makes sense
      if ($::graphite::gr_web_server_port == 80 and $::graphite::gr_web_server_remove_default == undef) or ($::graphite::gr_web_server_remove_default == true) {
        file { '/etc/nginx/sites-enabled/default':
          ensure  => absent,
          require => Package['nginx'],
          notify  => Service['nginx'];
        }
      }

    } # Finish Debian config
    
    # Config for RedHat
    'RedHat': {
      
      # Ensure that some directories exist first. This is normally handled by the
      # package, but if we uninstall and reinstall nginx and delete /etc/nginx.
      # By default the package manager won't replace the directory.
      file {
        '/etc/nginx/conf.d':
          ensure  => directory,
          mode    => '0755',
          require => File['/etc/nginx'];
      }

      # Deploy config file for site
      file {
        '/etc/nginx/conf.d/graphite.conf':
          ensure  => file,
          mode    => '0644',
          content => template('graphite/etc/nginx/sites-available/graphite.erb'),
          require => [
            File['/etc/nginx/conf.d'],
            Exec['Initial django db creation']
          ],
          notify  => Service['nginx'];
      }

      # Remove default config file, but only when it makes sense
      if ($::graphite::gr_web_server_port == 80 and $::graphite::gr_web_server_remove_default == undef) or ($::graphite::gr_web_server_remove_default == true) {
        file { '/etc/nginx/conf.d/default.conf':
          ensure  => absent,
          require => Package['nginx'],
          notify  => Service['nginx'],
        }
      }

    }

    default: {
      fail('Only Debian and RedHat-like systems are supported.')
    }
  
  }

  service {
    'nginx':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true;
  }


  # HTTP basic authentication
  $nginx_htpasswd_file_presence = $::graphite::nginx_htpasswd ? {
    undef   => absent,
    default => file,
  }

  file {
    '/etc/nginx/graphite-htpasswd':
      ensure  => $nginx_htpasswd_file_presence,
      mode    => '0400',
      owner   => $::graphite::config::gr_web_user_REAL,
      content => $::graphite::nginx_htpasswd,
      require => Package['nginx'],
      notify  => Service['nginx'];
  }
}
