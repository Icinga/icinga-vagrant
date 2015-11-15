
class nagvis::params (
  $monitoring_type = 'icinga',
  $nagvis_version = '1.8.5',
  $prefix = '/usr/local/nagvis',
  $http_user = 'apache',
  $http_group = 'apache',
  $http_conf_dir = '/etc/httpd/conf.d',
  $backend_name = 'ndomy_1',
  $backend_ido_db_host = 'localhost',
  $backend_ido_db_port = 3306,
  $backend_ido_db_name = 'icinga',
  $backend_ido_db_user = 'icinga',
  $backend_ido_db_pass = 'icinga',
  $backend_ido_db_prefix = 'icinga_',
  $backend_ido_db_instancename = 'default'
) {
  validate_re($monitoring_type, '^(icinga|nagios)$', "${monitoring_type} is not supported for monitoring_type. Allowed values are 'icinga' and 'nagios'.")
  validate_re($backend_name, '^(ndomy_1|live_1)$', "${backend_name} is not supported for backend_name. Allowed values are 'ndomy_1'.")
}
