# == Class: graphite::config_apache
#
# This class configures apache to proxy requests to graphite web and SHOULD
# NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::config_apache inherits graphite::params {

	Exec { path => '/bin:/usr/bin:/usr/sbin' }

	# we need an apache with python support

	package {
		"${::graphite::params::apache_pkg}":
			ensure => installed,
			before => Exec['Chown graphite for web user'],
			notify => Exec['Chown graphite for web user'];
	}

	package {
		"${::graphite::params::apache_wsgi_pkg}":
			ensure  => installed,
			require => Package["${::graphite::params::apache_pkg}"]
	}

	case $::osfamily {
		debian: {
			exec { 'Disable default apache site':
				command => 'a2dissite default',
				onlyif  => 'test -f /etc/apache2/sites-enabled/000-default',
				require => Package["${::graphite::params::apache_wsgi_pkg}"],
				notify  => Service["${::graphite::params::apache_service_name}"];
			}
		}
		redhat: {
			file { "${::graphite::params::apacheconf_dir}/welcome.conf":
				ensure  => absent,
				require => Package["${::graphite::params::apache_wsgi_pkg}"],
				notify  => Service["${::graphite::params::apache_service_name}"];
			}
		}
		default: {
			fail("Module graphite is not supported on ${::operatingsystem}")
		}
	}

	service { "${::graphite::params::apache_service_name}":
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require    => Exec['Chown graphite for web user'];
	}

	# Deploy configfiles
	file {
		"${::graphite::params::apache_dir}/ports.conf":
			ensure  => file,
			owner   => $::graphite::params::web_user,
			group   => $::graphite::params::web_user,
			mode    => '0644',
			content => template('graphite/etc/apache2/ports.conf.erb'),
			require => [
				Package["${::graphite::params::apache_wsgi_pkg}"],
				Exec['Initial django db creation'],
				Exec['Chown graphite for web user']
			];
		"${::graphite::params::apacheconf_dir}/graphite.conf":
			ensure  => file,
			owner   => $::graphite::params::web_user,
			group   => $::graphite::params::web_user,
			mode    => '0644',
			content => template('graphite/etc/apache2/sites-available/graphite.conf.erb'),
			require => [
				File["${::graphite::params::apache_dir}/ports.conf"],
			];
	}

	case $::osfamily {
		debian: {
			file { '/etc/apache2/sites-enabled/graphite.conf':
				ensure  => link,
				target  => "${::graphite::params::apacheconf_dir}/graphite.conf",
				require => File['/etc/apache2/sites-available/graphite.conf'],
				notify  => Service["${::graphite::params::apache_service_name}"];
			}
		}
		default: {}
	}
}
