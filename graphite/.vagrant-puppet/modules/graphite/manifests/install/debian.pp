# == Class: graphite::install::debian
#
# This class installs graphite/carbon/whisper on Debian and its derivates and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::install::debian {

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

	# Download graphite sources

	package { 'ca-certificates':
		# needed to download from httpS://github.com/
		ensure => installed,
	}
	exec {
		"Download and untar webapp ${::graphite::params::graphiteVersion}":
			require => Package['ca-certificates'],
			command => "wget -O - ${::graphite::params::webapp_dl_url} | tar xz",
			creates => "${::graphite::params::webapp_dl_loc}",
			cwd     => "${::graphite::params::build_dir}";
		"Download and untar carbon ${::graphite::params::carbonVersion}":
			require => Package['ca-certificates'],
			command => "wget -O - ${::graphite::params::carbon_dl_url} | tar xz",
			creates => "${::graphite::params::carbon_dl_loc}",
			cwd     => "${::graphite::params::build_dir}";
		"Download and untar whisper ${::graphite::params::whisperVersion}":
			require => Package['ca-certificates'],
			command => "wget -O - ${::graphite::params::whisper_dl_url} | tar xz",
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
				Anchor['graphitepkg::end']
			];
		"Install carbon ${::graphite::params::carbonVersion}":
			command     => 'python setup.py install',
			cwd         => "${::graphite::params::carbon_dl_loc}",
			subscribe   => Exec["Download and untar carbon ${::graphite::params::carbonVersion}"],
			refreshonly => true,
			require     => [
				Exec["Download and untar carbon ${::graphite::params::carbonVersion}"],
				Anchor['graphitepkg::end']
			];
		"Install whisper ${::graphite::params::whisperVersion}":
			command     => 'python setup.py install',
			cwd         => "${::graphite::params::whisper_dl_loc}",
			subscribe   => Exec["Download and untar whisper ${::graphite::params::whisperVersion}"],
			refreshonly => true,
			require     => [
				Exec["Download and untar whisper ${::graphite::params::whisperVersion}"],
				Anchor["graphitepkg::end"]
			];
	}
}

