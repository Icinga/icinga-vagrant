# == Class: graphite::params
#
# This class specifies default parameters for the graphite module and
# SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::params {
  $build_dir = '/usr/local/src/'

  $python_pip_pkg     = 'python-pip'
  $django_tagging_pkg = 'django-tagging'
  $django_tagging_ver = '0.3.1'
  $twisted_pkg        = 'Twisted'
  $twisted_ver        = '11.1.0'
  $txamqp_pkg         = 'txAMQP'
  $txamqp_ver         = '0.4'
  $graphite_pkg       = 'graphite-web'
  $graphite_ver       = '0.9.15'
  $carbon_pkg         = 'carbon'
  $carbon_ver         = '0.9.15'
  $whisper_pkg        = 'whisper'
  $whisper_ver        = '0.9.15'
  $django_pkg         = 'Django'
  $django_ver         = '1.5'
  $django_provider    = 'pip'

  $install_prefix     = '/opt/'

  # variables to workaround unusual graphite install target:
  # https://github.com/graphite-project/carbon/issues/86
  $pyver              = $::osfamily ? {
    'RedHat' => $::operatingsystemrelease ? {
      /^6/    => '2.6',
      default => '2.7'
    },
    default  => '2.7',
  }
  case $::osfamily {
    'Debian': {
      $apache_dir                = '/etc/apache2'
      $apache_pkg                = 'apache2'
      $apache_service_name       = 'apache2'
      $apache_wsgi_pkg           = 'libapache2-mod-wsgi'
      $apache_wsgi_socket_prefix = '/var/run/apache2/wsgi'
      $apacheconf_dir            = '/etc/apache2/sites-available'
      $apacheports_file          = 'ports.conf'
      $apache_logdir_graphite    = '/var/log/apache2/graphite-web'

      $nginxconf_dir    = '/etc/nginx/sites-available'

      $apache_web_group = 'www-data'
      $apache_web_user  = 'www-data'
      $nginx_web_group  = 'www-data'
      $nginx_web_user   = 'www-data'

      $python_dev_pkg = 'python-dev'

      $common_os_pkgs = [
        'python-tz',
        'python-ldap',
        'python-memcache',
        'python-mysqldb',
        'python-psycopg2',
        'python-simplejson',
        'python-sqlite',
      ]

      if $::operatingsystem == 'Ubuntu' {
        if versioncmp($::lsbdistrelease, '15.10') == -1 {
          $service_provider   = 'debian'
        } else {
          $service_provider   = 'systemd'
        }
      } elsif $::operatingsystem == 'Debian' {
        if versioncmp($::lsbdistrelease, '8.0') == -1 {
          $service_provider   = 'debian'
        } else {
          $service_provider   = 'systemd'
        }
      }

      case $::lsbdistcodename {
        /squeeze|wheezy|precise/: {
          $apache_24          = false
          $graphitepkgs       = union($common_os_pkgs, ['python-cairo',])
        }

        /jessie|trusty|utopic|vivid|wily/: {
          $apache_24          = true
          $graphitepkgs       = union($common_os_pkgs, ['python-cairo',])
        }

        default: {
          fail("Unsupported Debian release: '${::lsbdistcodename}'")
        }
      }
      $libpath = "/usr/lib/python${pyver}/dist-packages"
    }

    'RedHat': {
      $apache_dir                = '/etc/httpd'
      $apache_pkg                = 'httpd'
      $apache_service_name       = 'httpd'
      $apache_wsgi_pkg           = 'mod_wsgi'
      $apache_wsgi_socket_prefix = 'run/wsgi'
      $apacheconf_dir            = '/etc/httpd/conf.d'
      $apacheports_file          = 'graphite_ports.conf'
      $apache_logdir_graphite    = '/var/log/httpd/graphite-web'

      $nginxconf_dir    = '/etc/nginx/conf.d'

      $apache_web_group = 'apache'
      $apache_web_user  = 'apache'
      $nginx_web_group  = 'nginx'
      $nginx_web_user   = 'nginx'

      $python_dev_pkg = ['python-devel','gcc']
      $common_os_pkgs = [
        'MySQL-python',
        'pyOpenSSL',
        'python-ldap',
        'python-memcached',
        'python-psycopg2',
        'python-zope-interface',
        'python-tzlocal',
      ]

      # see https://github.com/graphite-project/carbon/issues/86
      case $::operatingsystemrelease {
        /^6\.\d+$/: {
          $apache_24           = false
          $graphitepkgs        = union($common_os_pkgs,['python-sqlite2', 'bitmap-fonts-compat', 'bitmap', 'pycairo','python-crypto'])
          $service_provider    = 'redhat'
        }

        /^7\.\d+/: {
          $apache_24           = true
          $graphitepkgs        = union($common_os_pkgs,['python-sqlite3dbm', 'dejavu-fonts-common', 'dejavu-sans-fonts', 'python-cairocffi','python2-crypto'])
          $service_provider    = 'systemd'
        }

        default: {
          fail("Unsupported RedHat release: '${::operatingsystemrelease}'")
        }
      }
      $libpath = "/usr/lib/python${pyver}/site-packages"
    }

    default: {
      fail("unsupported os, ${::operatingsystem}.")
    }
  }

}
