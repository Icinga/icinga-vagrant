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
  $graphite_ver       = '0.9.12'
  $carbon_pkg         = 'carbon'
  $carbon_ver         = '0.9.12'
  $whisper_pkg        = 'whisper'
  $whisper_ver        = '0.9.12'

  $django_ver         = 'installed'
  $django_provider    = undef

  $install_prefix     = '/opt/'
  $nginxconf_dir      = '/etc/nginx/sites-available'

  case $::osfamily {
    'Debian': {
      $apache_dir                = '/etc/apache2'
      $apache_pkg                = 'apache2'
      $apache_service_name       = 'apache2'
      $apache_wsgi_pkg           = 'libapache2-mod-wsgi'
      $apache_wsgi_socket_prefix = '/var/run/apache2/wsgi'
      $apacheconf_dir            = '/etc/apache2/sites-available'
      $apacheports_file          = 'ports.conf'

      $web_group = 'www-data'
      $web_user = 'www-data'

      $python_dev_pkg = 'python-dev'

      $django_pkg = 'python-django'
      $graphitepkgs = [
        'python-tz',
        'python-cairo',
        'python-ldap',
        'python-memcache',
        'python-mysqldb',
        'python-psycopg2',
        'python-simplejson',
        'python-sqlite',
      ]

      case $::lsbdistcodename {
        /squeeze|wheezy|precise/: {
          $apache_24               = false
        }

        /jessie|trusty|utopic|vivid/: {
          $apache_24               = true
        }

        default: {
          fail("Unsupported Debian release: '${::lsbdistcodename}'")
        }
      }
    }

    'RedHat': {
      $apache_dir                = '/etc/httpd'
      $apache_pkg                = 'httpd'
      $apache_service_name       = 'httpd'
      $apache_wsgi_pkg           = 'mod_wsgi'
      $apache_wsgi_socket_prefix = 'run/wsgi'
      $apacheconf_dir            = '/etc/httpd/conf.d'
      $apacheports_file          = 'graphite_ports.conf'

      $web_group = 'apache'
      $web_user = 'apache'

      $python_dev_pkg = ['python-devel','gcc']
      $common_os_pkgs = [
        'MySQL-python',
        'bitmap',
        'bitmap-fonts-compat',
        'pyOpenSSL',
        'pycairo',
        'python-crypto',
        'python-ldap',
        'python-memcached',
        'python-psycopg2',
        'python-zope-interface',
      ]

      # see https://github.com/graphite-project/carbon/issues/86
      case $::operatingsystemrelease {
        /^6\.\d+$/: {
          $apache_24    = false
          $django_pkg = 'Django14'
          $graphitepkgs = union($common_os_pkgs,['python-sqlite2'])
        }

        /^7\.\d+/: {
          $apache_24    = true
          $django_pkg = 'python-django'
          $graphitepkgs = union($common_os_pkgs,['python-sqlite3dbm'])
        }

        default: {
          fail("Unsupported RedHat release: '${::operatingsystemrelease}'")
        }
      }
    }

    default: {
      fail("unsupported os, ${::operatingsystem}.")
    }
  }

}
