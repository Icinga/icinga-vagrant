class profiles::icingaweb2::install {
  include '::icingaweb2' # TODO: Replace with official module with Puppet 5 support
  include '::icingaweb2_internal_db_mysql' # TODO: Move this into a specific profile
}
