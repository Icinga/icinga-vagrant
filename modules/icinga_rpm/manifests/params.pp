class icinga_rpm::params {
  # use snapshot repositories by default
  $pkg_repo_version			= 'snapshot'
  $pkg_repo_release_key			= 'http://packages.icinga.com/icinga.key'
  $pkg_repo_release_metadata_expire	= undef
  $pkg_repo_release_url              	= 'http://packages.icinga.com/epel/$releasever/release'
  $pkg_repo_snapshot_key             	= 'http://packages.icinga.com/icinga.key'
  $pkg_repo_snapshot_metadata_expire 	= '1d'
  $pkg_repo_snapshot_url		= 'http://packages.icinga.com/epel/$releasever/snapshot'
}
