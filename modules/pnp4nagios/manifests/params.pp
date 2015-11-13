
class pnp4nagios::params (
  $ensure = present,
  $monitoring_type = 'icinga',
  $perfdata_spool_dir = '/var/spool/icinga2/perfdata',
  $log_type = 'file',
  $debug_lvl = 0,
) {
  validate_re($log_type, '^(syslog|file)$', "${log_type} is not supported for log_type. Allowed values are 'syslog' and 'file'.")
  validate_re($monitoring_type, '^(icinga|nagios)$', "${monitoring_type} is not supported for monitoring_type. Allowed values are 'icinga' and 'nagios'.")
}
