class profiles::graphite::server (
  $listen_ip,
  $listen_port,
  $graphite_fqdn = 'graphite.vagrant.demo.icinga.com',
  # http://graphite.readthedocs.io/en/latest/install.html#dependencies
  $version = '1.1.2',
  $twisted_version = '13.2.0', #https://github.com/graphite-project/carbon/issues/688
  $django_version = '1.11',
  $django_tagging_version = '0.4.6' #https://github.com/graphite-project/graphite-web/issues/1249
) {

  # avoid SQLite locks
  mysql::db { 'graphite':
    user      => 'graphite',
    password  => 'graphite',
    host      => 'localhost',
    charset   => 'latin1',
    collate   => 'latin1_swedish_ci',
    grant     => [ 'ALL' ]
  }

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
  class { 'graphite':
    gr_web_server           => 'none',
    gr_web_user             => 'apache',
    gr_web_group            => 'apache',
    gr_pip_install => true,
    gr_manage_python_packages => false, #workaround for EPEL rename of python-pip to python2-pip
    # version management
    gr_graphite_ver => $version,
    gr_carbon_ver => $version,
    gr_whisper_ver => $version,
    gr_twisted_ver => $twisted_version,
    gr_django_ver  => $django_version,
    gr_django_tagging_ver => $django_tagging_version,
    # required for Graphite 1.1.x
    #gr_django_init_command => 'PYTHONPATH=/opt/graphite/webapp /usr/lib/python2.7/site-packages/django/bin/django-admin.py migrate --settings=graphite.settings --run-syncdb',
    # first, create the DB.
    # second, collect static content like images and JS. Served via Apache below.
    gr_django_init_command => 'export PYTHONPATH=/opt/graphite/webapp; /usr/lib/python2.7/site-packages/django/bin/django-admin.py migrate --settings=graphite.settings --run-syncdb; /usr/lib/python2.7/site-packages/django/bin/django-admin.py collectstatic --noinput --settings=graphite.settings',
    gr_django_init_provider => 'shell', # important, override posix
    # database backend
    gr_django_db_engine       => 'django.db.backends.mysql',
    gr_django_db_name         => 'graphite',
    gr_django_db_user         => 'graphite',
    gr_django_db_password     => 'graphite',
    gr_django_db_host         => 'localhost',
    gr_django_db_port         => '3306',
    # logging
    gr_graphiteweb_log_dir    => '/opt/graphite/storage/log/webapp',
    # general settings
    gr_disable_webapp_cache => true,
    secret_key => 'ICINGA2ROCKS',
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
  }
  ->
  # fix the permission problem for apache logs
  exec { 'fix-graphite-web-log-perms':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'chown -R apache:apache /opt/graphite/storage'
  }

  apache::vhost { "${graphite_fqdn}":
    port    => $listen_port,
    docroot => '/opt/graphite/webapp',
    # this is important for static content such as images and JS in 1.x
    aliases => [
    {
      alias => '/static/',
      path  => '/opt/graphite/static/'
    }
    ],
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
}
