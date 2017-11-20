class profiles::graphite::server (
  $listen_ip = '192.168.33.5',
  $listen_port = 8003,
  $graphite_fqdn = 'graphite.vagrant.demo.icinga.com'
) {

  # TODO: Update to 1.0.0
  # 0.9.14 requires pytz: https://github.com/graphite-project/graphite-web/issues/1019
  package { 'pytz':
    ensure => 'installed',
  }
  ->
  # avoid a bug in the pip provider
  # https://github.com/echocat/puppet-graphite/issues/180
  file { 'pip-symlink':
    ensure	=> symlink,
    path	=> '/usr/bin/pip-python',
    target	=> '/usr/bin/pip',
    before	=> Class['graphite'],
  }
  ->
  file { '/opt/graphite':
    ensure => directory
  }->
  # workaround for EPEL rename of python-pip to python2-pip, http://smoogespace.blogspot.de/2016/12/why-are-epel-python-packages-getting.html
  # pip also requires additional packages: http://graphite.readthedocs.io/en/latest/install-pip.html
  package { [ 'python2-pip',
  	    'python-devel',
  	    'cairo-devel',
  	    'libffi-devel',
  	    'gcc' ]:
    ensure => 'installed',
  }
  ->
  apache::vhost { "${graphite_fqdn}":
    port    => $listen_port,
    docroot => '/opt/graphite/webapp',
    wsgi_application_group      => '%{GLOBAL}',
    wsgi_daemon_process         => 'graphite',
    wsgi_daemon_process_options => {
      processes          => '5',
      threads            => '5',
      display-name       => '%{GROUP}',
      inactivity-timeout => '120',
    },
    wsgi_import_script          => '/opt/graphite/conf/graphite_wsgi.py',
    wsgi_import_script_options  => {
      process-group     => 'graphite',
      application-group => '%{GLOBAL}'
    },
    wsgi_process_group          => 'graphite',
    wsgi_script_aliases         => {
      '/' => '/opt/graphite/conf/graphite_wsgi.py'
    },
    headers => [
      'set Access-Control-Allow-Origin "*"',
      'set Access-Control-Allow-Methods "GET, OPTIONS, POST"',
      'set Access-Control-Allow-Headers "origin, authorization, accept"',
    ],
    directories => [{
      path => '/media/',
    }
    ]
  }
  ->
  class { 'graphite':
    gr_web_server           => 'none',
    gr_web_user             => 'apache',
    gr_web_group            => 'apache',
    gr_disable_webapp_cache => true,
    secret_key => 'ICINGA2ROCKS',
    gr_pip_install => true,
    gr_manage_python_packages => false, #workaround for EPEL rename of python-pip to python2-pip
    gr_graphite_ver => '0.9.14',
    gr_carbon_ver => '0.9.14',
    gr_whisper_ver => '0.9.14',
    gr_twisted_ver => '13.2.0', # 0.9.14 carbon-cache requirement
    gr_timezone => 'Europe/Berlin',
    gr_max_updates_per_second => 10000,
    gr_max_creates_per_minute => 1000,
    gr_storage_schemas => [
      {
        name       => 'carbon',
        pattern    => '^carbon\.',
        retentions => '1m:90d'
      },
      {
        name       => 'icinga2_default',
        pattern    => '^icinga2\.',
        retentions => '1m:2d,5m:10d,30m:90d,360m:4y'
      },
      {
        name       => 'default',
        pattern    => '.*',
        retentions => '1m:14d'
      }
    ],
    require => Apache::Vhost["${graphite_fqdn}"]
  }

  # TODO: Nginx instead of Apache
  # https://gist.github.com/jasonjayr/3344812


}
