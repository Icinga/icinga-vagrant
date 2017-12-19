class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }

$icinga_dev_pkg = [ 'gcc', 'autoconf', 'glibc', 'glibc-common', 'gd', 'gd-devel', 'libpng', 'libpng-devel',
			'libdbi', 'libdbi-devel', 'libdbi-drivers', 'libdbi-dbd-mysql' ]

package { $icinga_dev_pkg:
  ensure => installed
}

group { [ 'icinga', 'icingacmd' ]: ensure => present }
user { [ 'vagrant', 'icinga' ] : ensure => present }

User<| title == vagrant |>{
  groups +> ['icinga', 'icingacmd'],
  require => Group['icinga']
}
User<| title == $::apache::params::user |>{
  groups +> ['icinga', 'icingacmd'],
  require => Group['icinga']
}
