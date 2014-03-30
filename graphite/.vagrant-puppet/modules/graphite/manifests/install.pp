# == Class: graphite::install
#
# This class calls the OS specific install classes and SHOULD NOT be called directly.
#
# === Parameters
#
# None.
#
class graphite::install inherits graphite::params {

	anchor { 'graphite::install::begin': }
	anchor { 'graphite::install::end': }

	case $::osfamily {
		redhat: {
			class { 'graphite::install::redhat':
				require => Anchor['graphite::install::begin'],
				before  => Anchor['graphite::install::end'],
			}
		}
    		debian: {
			class { 'graphite::install::debian':
				require => Anchor['graphite::install::begin'],
				before  => Anchor['graphite::install::end'],
			}
		}
		default: {
			fail("Module graphite is not supported on ${::operatingsystem}")
		}
	}
}
