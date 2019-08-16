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

  $django_tagging_pkg    = 'django-tagging'
  $django_tagging_ver    = '0.3.1'
  $django_tagging_source = undef
  $twisted_pkg           = 'Twisted'
  $twisted_ver           = '11.1.0'
  $twisted_source        = undef
  $txamqp_pkg            = 'txAMQP'
  $txamqp_ver            = '0.4'
  $txamqp_source         = undef
  $graphite_pkg          = 'graphite-web'
  $graphite_ver          = '0.9.15'
  $graphite_source       = undef
  $carbon_pkg            = 'carbon'
  $carbon_ver            = '0.9.15'
  $carbon_source         = undef
  $whisper_pkg           = 'whisper'
  $whisper_ver           = '0.9.15'
  $whisper_source        = undef
  $django_pkg            = 'Django'
  $django_ver            = '1.5'
  $django_source         = undef
  $django_provider       = 'pip'
  $pip_install_options   = undef
  $python_binary         = 'python'

  $install_prefix     = '/opt/'

  # variables for django db initialization
  $django_init_provider = 'posix'

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
      $python_pip_pkg            = 'python-pip'
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
        'python-setuptools',
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
          $apache_24                 = false
          $graphitepkgs              = union($common_os_pkgs, ['python-cairo',])
          $libpath                   = "/usr/lib/python${pyver}/dist-packages"
          $extra_pip_install_options = undef
        }

        /stretch|jessie|trusty|utopic|vivid|wily/: {
          $apache_24                 = true
          $graphitepkgs              = union($common_os_pkgs, ['python-cairo',])
          $libpath                   = "/usr/lib/python${pyver}/dist-packages"
          $extra_pip_install_options = undef
        }

        /xenial|bionic/: {
          $apache_24                 = true
          $graphitepkgs              = union($common_os_pkgs, ['python-cairo',])
          $libpath                   = "/usr/local/lib/python${pyver}/dist-packages"
          $extra_pip_install_options = [{'--no-binary' => ':all:'}]
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
      $apache_wsgi_socket_prefix = 'run/wsgi'
      $apacheconf_dir            = '/etc/httpd/conf.d'
      $apacheports_file          = 'graphite_ports.conf'
      $apache_logdir_graphite    = '/var/log/httpd/graphite-web'

      $nginxconf_dir    = '/etc/nginx/conf.d'

      $apache_web_group = 'apache'
      $apache_web_user  = 'apache'
      $nginx_web_group  = 'nginx'
      $nginx_web_user   = 'nginx'

      if $::operatingsystem =~ /^[Aa]mazon$/ {
        $_pyver          = regsubst($pyver, '\.', '')
        $python          = "python${_pyver}"
        $pyopenssl       = "${python}-pyOpenSSL"
        $apache_wsgi_pkg = "mod_wsgi-${python}"
        $pytz            = "${python}-pytz"
        $python_pip_pkg  = "${python}-pip"
      } else {
        $python          = 'python'
        $pyopenssl       = 'pyOpenSSL'
        $apache_wsgi_pkg = 'mod_wsgi'
        $pytz            = 'python-tzlocal'
        $python_pip_pkg  = $::osfamily ? {
          'RedHat'  => $::operatingsystemrelease ? {
            /^7/    => 'python2-pip',
            default => 'python-pip'
          },
          default   => 'python-pip',
        }
      }

      $python_dev_pkg = ["${python}-devel", 'gcc']
      $common_os_pkgs = [
        "MySQL-${python}",
        $pyopenssl,
        "${python}-ldap",
        "${python}-memcached",
        "${python}-psycopg2",
        "${python}-zope-interface",
        $pytz,
      ]

      # see https://github.com/graphite-project/carbon/issues/86
      case $::operatingsystemrelease {
        /^6\.\d+$/: {
          $apache_24        = false
          $graphitepkgs     = union($common_os_pkgs,['python-sqlite2', 'bitmap-fonts-compat', 'bitmap', 'pycairo','python-crypto'])
          $service_provider = 'redhat'
        }

        /^7\.\d+/: {
          $apache_24        = true
          $graphitepkgs     = union($common_os_pkgs,['python-sqlite3dbm', 'dejavu-fonts-common', 'dejavu-sans-fonts', 'python-cairocffi','python2-crypto'])
          $service_provider = 'systemd'
        }

        # Amazon Linux 20xx.xx
        /^20\d{2}.\d{2}/: {
          $apache_24        = false
          $graphitepkgs     = union($common_os_pkgs,['bitmap', "${python}-pycairo","${python}-crypto"])
          $service_provider = 'redhat'
        }

        default: {
          fail("Unsupported RedHat release: '${::operatingsystemrelease}'")
        }
      }

      $libpath = "/usr/lib/python${pyver}/site-packages"

      $extra_pip_install_options = undef
    }

    default: {
      fail("unsupported os, ${::operatingsystem}.")
    }
  }

}
