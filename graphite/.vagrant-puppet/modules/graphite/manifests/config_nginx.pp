# == Class: graphite::config_nginx
#
# This class configures graphite/carbon/whisper and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::config_nginx inherits graphite::params {

	Exec { path => '/bin:/usr/bin:/usr/sbin' }

	if $::osfamily != 'debian' {
		fail("nginx-based graphite is not supported on ${::operatingsystem} (only supported on Debian)")
	}

	# we need a nginx with gunicorn for python support

	package {
		'nginx':
			ensure => installed,
			before => Exec['Chown graphite for web user'],
			notify => Exec['Chown graphite for web user'];
		'gunicorn':
			ensure => installed;
	}

	exec { 'Disable default nginx site':
		command => 'unlink /etc/nginx/sites-enabled/default',
		onlyif  => 'test -f /etc/nginx/sites-enabled/default',
		require => Package['nginx'],
		notify  => Service['nginx'];
	}

	service {
		'nginx':
			ensure     => running,
			enable     => true,
			hasrestart => true,
			hasstatus  => true,
			require    => Exec['Chown graphite for web user'];
		'gunicorn':
			ensure     => running,
			enable     => true,
			hasrestart => true,
			hasstatus  => false,
			subscribe  => File['/opt/graphite/webapp/graphite/local_settings.py'],
			require    => [
				Package['gunicorn'],
				Exec['Chown graphite for web user'],
			];
	}

	# Deploy configfiles

	file {
		'/etc/gunicorn.d/graphite':
			ensure  => file,
			mode    => '0644',
			content => template('graphite/etc/gunicorn.d/graphite.erb'),
			require => Package['gunicorn'],
			notify  => Service['gunicorn'];
		'/etc/nginx/sites-available/graphite':
			ensure  => file,
			mode    => '0644',
			content => template('graphite/etc/nginx/sites-available/graphite.erb'),
			require => [
				Package['nginx'],
				Exec['Initial django db creation'],
				Exec['Chown graphite for web user']
			];
		'/etc/nginx/sites-enabled/graphite':
			ensure  => link,
			target  => '/etc/nginx/sites-available/graphite',
			require => File['/etc/nginx/sites-available/graphite'],
			notify  => Service['nginx'];
	}

	# HTTP basic authentication
	$nginx_htpasswd_file_presence = $graphite::nginx_htpassword ? {
		undef   => absent,
		default => file,
	}
	file {
		'/etc/nginx/graphite-htpasswd':
			ensure  => $nginx_htpasswd_file_presence,
			mode    => '0400',
			owner   => "${::graphite::params::web_user}",
			content => $graphite::nginx_htpassword,
			require => Package['nginx'],
			notify  => Service['nginx'];
	}

}
