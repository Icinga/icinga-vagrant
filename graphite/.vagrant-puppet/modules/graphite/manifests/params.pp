# == Class: graphite::params
#
# This class specifies default parameters for the graphite module and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::params {
  $build_dir = '/usr/local/src/'

  $graphiteVersion = '0.9.12'
  $carbonVersion   = '0.9.12'
  $whisperVersion  = '0.9.12'

  $whisper_dl_url = "http://github.com/graphite-project/whisper/archive/${::graphite::params::whisperVersion}.tar.gz"
  $whisper_dl_loc = "${build_dir}/whisper-${::graphite::params::whisperVersion}"

  $webapp_dl_url = "http://github.com/graphite-project/graphite-web/archive/${::graphite::params::graphiteVersion}.tar.gz"
  $webapp_dl_loc = "${build_dir}/graphite-web-${::graphite::params::graphiteVersion}"

  $carbon_dl_url = "https://github.com/graphite-project/carbon/archive/${::graphite::params::carbonVersion}.tar.gz"
  $carbon_dl_loc = "${build_dir}/carbon-${::graphite::params::carbonVersion}"

  $install_prefix = '/opt/'

  $apache_pkg = $::osfamily ? {
    debian => 'apache2',
    redhat => 'httpd',
  }

  $apache_wsgi_pkg = $::osfamily ? {
    debian => 'libapache2-mod-wsgi',
    redhat => 'mod_wsgi',
  }

  $apache_wsgi_socket_prefix = $::osfamily ? {
    debian => '/var/run/apache2/wsgi',
    redhat => 'run/wsgi',
  }

  $apache_service_name = $::osfamily ? {
    debian => 'apache2',
    redhat => 'httpd',
  }

  $apacheconf_dir = $::osfamily ? {
    debian => '/etc/apache2/sites-available',
    redhat => '/etc/httpd/conf.d',
  }

  $apache_dir = $::osfamily ? {
    debian => '/etc/apache2',
    redhat => '/etc/httpd',
  }

  $nginxconf_dir = '/etc/nginx/sites-available'

  $web_server_pkg = $graphite::gr_web_server ? {
    apache  => $apache_pkg,
    nginx   => 'nginx',
    default => fail('The only supported web servers are \'apache\' and \'nginx\''),
  }

  $web_user = $::osfamily ? {
    debian => 'www-data',
    redhat => 'apache',
  }

  $graphitepkgs = $::osfamily ? {
    debian => ["python-cairo","python-twisted","python-django","python-django-tagging","python-ldap","python-memcache","python-sqlite","python-simplejson"],
    redhat => ["pycairo", "Django14", "python-ldap", "python-memcached", "python-sqlite2",  "bitmap", "bitmap-fonts-compat", "python-devel", "python-crypto", "pyOpenSSL", "gcc", "python-zope-filesystem", "python-zope-interface", "git", "gcc-c++", "zlib-static", "MySQL-python"],
  }

}
