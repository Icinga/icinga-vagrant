# == Class: graphite::install::redhat
#
# This class installs graphite/carbon/whisper on Redhat and its derivates and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::install::redhat {

	include graphite::params

	Exec { path => '/bin:/usr/bin:/usr/sbin' }

	# for full functionality we need this packages:
	# madatory: python-cairo, python-django, python-twisted, python-django-tagging, python-simplejson
	# optinal: python-ldap, python-memcache, memcached, python-sqlite

	anchor { 'graphitepkg::begin': }
	anchor { 'graphitepkg::end': }

	package { $::graphite::params::graphitepkgs :
		ensure  => installed,
		require => Anchor['graphitepkg::begin'],
		before  => Anchor['graphitepkg::end']
	}

	# Install required python env special for redhat and derivatives

	package { 'python-setuptools':
		ensure  => installed,
		require => Anchor['graphitepkg::begin'],
		before  => Anchor['graphitepkg::end']
	}

	exec {
		'Install django-tagging':
			command => 'easy_install django-tagging',
			cwd     => "${::graphite::params::build_dir}",
			require => Anchor['graphitepkg::end'];
		'Install twisted':
			command => 'easy_install twisted',
			cwd     => "${::graphite::params::build_dir}",
			require => Anchor['graphitepkg::end'];
		'Install txamqp':
			command => 'easy_install txamqp',
			cwd     => "${::graphite::params::build_dir}",
			require => Anchor['graphitepkg::end'];
	}

	# Download graphite sources

	exec {
		"Download and untar webapp ${::graphite::params::graphiteVersion}":
			command => "curl -s -L ${::graphite::params::webapp_dl_url} | tar xz",
			creates => "${::graphite::params::webapp_dl_loc}",
			cwd     => "${::graphite::params::build_dir}";
		"Download and untar carbon ${::graphite::params::carbonVersion}":
			command => "curl -s -L ${::graphite::params::carbon_dl_url} | tar xz",
			creates => "${::graphite::params::carbon_dl_loc}",
			cwd     => "${::graphite::params::build_dir}";
		"Download and untar whisper ${::graphite::params::whisperVersion}":
			command => "curl -s -L ${::graphite::params::whisper_dl_url} | tar xz",
			creates => "${::graphite::params::whisper_dl_loc}",
			cwd     => "${::graphite::params::build_dir}";
	}

	# Install graphite from source

	exec {
		"Install webapp ${::graphite::params::graphiteVersion}":
			command     => 'python setup.py install',
			cwd         => "${::graphite::params::webapp_dl_loc}",
			subscribe   => Exec["Download and untar webapp ${::graphite::params::graphiteVersion}"],
			refreshonly => true,
			require     => [
				Exec["Download and untar webapp ${::graphite::params::graphiteVersion}"],
				Exec["Install django-tagging"]
			];
		"Install carbon ${::graphite::params::carbonVersion}":
			command     => 'python setup.py install',
			cwd         => "${::graphite::params::carbon_dl_loc}",
			subscribe   => Exec["Download and untar carbon ${::graphite::params::carbonVersion}"],
			refreshonly => true,
			require     => [
				Exec["Download and untar carbon ${::graphite::params::carbonVersion}"],
				Exec["Install twisted"]
			];
		"Install whisper ${::graphite::params::whisperVersion}":
			command     => 'python setup.py install',
			cwd         => "${::graphite::params::whisper_dl_loc}",
			subscribe   => Exec["Download and untar whisper ${::graphite::params::whisperVersion}"],
			refreshonly => true,
			require     => [
				Exec["Download and untar whisper ${::graphite::params::whisperVersion}"],
				Exec["Install twisted"]
			];
	}
}

