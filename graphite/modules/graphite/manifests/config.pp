# == Class: graphite::config
#
# This class configures graphite/carbon/whisper and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::config inherits graphite::params {

	anchor { 'graphite::config::begin': }
	anchor { 'graphite::config::end': }

	Exec { path => '/bin:/usr/bin:/usr/sbin' }

	# for full functionality we need this packages:
	# mandatory: python-cairo, python-django, python-twisted, python-django-tagging, python-simplejson
	# optional: python-ldap, python-memcache, memcached, python-sqlite

	# we need an web server with python support
	# apache with mod_wsgi or nginx with gunicorn
	case $graphite::gr_web_server {
		'apache': {
			include graphite::config_apache
		}
		'nginx': {
			include graphite::config_nginx
		}
		default: {
			fail('The only supported web servers are \'apache\' and \'nginx\'')
		}
	}

	# first init of user db for graphite

	exec { 'Initial django db creation':
		command     => 'python manage.py syncdb --noinput',
		cwd         => '/opt/graphite/webapp/graphite',
		refreshonly => true,
		notify      => Exec['Chown graphite for web user'],
		subscribe   => Exec["Install webapp ${::graphite::params::graphiteVersion}"],
		before      => Exec['Chown graphite for web user'],
		require     => File['/opt/graphite/webapp/graphite/local_settings.py'];
	}

	# change access permissions for web server

	exec { 'Chown graphite for web user':
		command     => "chown -R ${::graphite::params::web_user}:${::graphite::params::web_user} /opt/graphite/storage/",
		cwd         => '/opt/graphite/',
		refreshonly => true,
		require     => [
			Anchor['graphite::install::end'],
			Package["${::graphite::params::web_server_pkg}"]
		]
	}

	# Deploy configfiles

	file {
		'/opt/graphite/webapp/graphite/local_settings.py':
			ensure  => file,
			owner   => $::graphite::params::web_user,
			group   => $::graphite::params::web_user,
			mode    => '0644',
			content => template("graphite/opt/graphite/webapp/graphite/local_settings.py.erb"),
			require => Package["${::graphite::params::web_server_pkg}"];
		'/opt/graphite/conf/graphite.wsgi':
			ensure  => file,
			owner   => $::graphite::params::web_user,
			group   => $::graphite::params::web_user,
			mode    => '0644',
			content => template("graphite/opt/graphite/conf/graphite.wsgi.erb"),
			require => Package["${::graphite::params::web_server_pkg}"];
	}

	# configure carbon engine

	file {
		'/opt/graphite/conf/storage-schemas.conf':
			mode    => '0644',
			content => template('graphite/opt/graphite/conf/storage-schemas.conf.erb'),
			require => Anchor['graphite::install::end'],
			notify  => Service['carbon-cache'];
		'/opt/graphite/conf/carbon.conf':
			mode    => '0644',
			content => template('graphite/opt/graphite/conf/carbon.conf.erb'),
			require => Anchor['graphite::install::end'],
			notify  => Service['carbon-cache'];
	}


	# configure logrotate script for carbon

	file { '/opt/graphite/bin/carbon-logrotate.sh':
		ensure  => file,
		mode    => '0544',
		content => template('graphite/opt/graphite/bin/carbon-logrotate.sh.erb'),
		require => Anchor['graphite::install::end'];
	}

	cron { 'Rotate carbon logs':
		command => '/opt/graphite/bin/carbon-logrotate.sh',
		user    => root,
		hour    => 1,
		minute  => 15,
		require => File['/opt/graphite/bin/carbon-logrotate.sh'];
	}

	# startup carbon engine

	service { 'carbon-cache':
		ensure     => running,
		enable     => true,
		hasstatus  => true,
		hasrestart => true,
		before     => Anchor['graphite::config::end'],
		require    => File['/etc/init.d/carbon-cache'];
	}

	file { '/etc/init.d/carbon-cache':
		ensure  => file,
		mode    => '0750',
		content => template('graphite/etc/init.d/carbon-cache.erb'),
		require => File['/opt/graphite/conf/carbon.conf'];
	}
}
