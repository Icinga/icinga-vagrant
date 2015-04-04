# Class: icinga_rpm
#
#   Configure Icinga repositories.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include icinga_rpm
#
class icinga_rpm (
  $pkg_repo_version = $::icinga_rpm::params::pkg_repo_version,
  $pkg_repo_release_key = $::icinga_rpm::params::pkg_repo_release_key,
  $pkg_repo_release_metadata_expire = $::icinga_rpm::params::pkg_repo_release_metadata_expire,
  $pkg_repo_release_url = $::icinga_rpm::params::pkg_repo_release_url,
  $pkg_repo_snapshot_key = $::icinga_rpm::params::pkg_repo_snapshot_key,
  $pkg_repo_snapshot_metadata_expire = $::icinga_rpm::params::pkg_repo_snapshot_metadata_expire,
  $pkg_repo_snapshot_url = $::icinga_rpm::params::pkg_repo_snapshot_url,
) inherits icinga_rpm::params {

  if $pkg_repo_release_metadata_expire {
    validate_string($pkg_repo_release_metadata_expire)
  }

  if $pkg_repo_snapshot_metadata_expire {
    validate_string($pkg_repo_snapshot_metadata_expire)
  }

  validate_re($pkg_repo_version,
    [
      'release',
      'snapshot',
    ]
  )

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Scientific': {
      case $pkg_repo_version {
        'release': {
          yumrepo { "ICINGA-${::icinga_rpm::pkg_repo_version}":
            baseurl         => $::icinga_rpm::pkg_repo_release_url,
            descr           => "ICINGA (${pkg_repo_version} builds for epel)",
            enabled         => 1,
            gpgcheck        => 1,
            gpgkey          => $::icinga_rpm::pkg_repo_release_key,
            metadata_expire => $::icinga_rpm::pkg_repo_release_metadata_expire,
          }
        }

        'snapshot': {
          yumrepo { "ICINGA-${::icinga_rpm::pkg_repo_version}":
            baseurl         => $::icinga_rpm::pkg_repo_snapshot_url,
            descr           => "ICINGA (${pkg_repo_version} builds for epel)",
            enabled         => 1,
            gpgcheck        => 1,
            gpgkey          => $::icinga_rpm::pkg_repo_snapshot_key,
            metadata_expire => $::icinga_rpm::pkg_repo_snapshot_metadata_expire,
          }
        }

        default: {}
      }
    }

    default: {}
  }
}

