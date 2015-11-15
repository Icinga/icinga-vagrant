
class nagvis::config {

  #  include nagvis::params
  $monitoring_type = $::nagvis::params::monitoring_type
  $backend_name = $::nagvis::params::backend_name
  $backend_ido_db_host = $::nagvis::params::backend_ido_db_host
  $backend_ido_db_port = $::nagvis::params::backend_ido_db_port
  $backend_ido_db_name = $::nagvis::params::backend_ido_db_name
  $backend_ido_db_user = $::nagvis::params::backend_ido_db_user
  $backend_ido_db_pass = $::nagvis::params::backend_ido_db_pass
  $backend_ido_db_prefix = $::nagvis::params::backend_ido_db_prefix
  $backend_ido_db_instancename = $::nagvis::params::backend_ido_db_instancename

  file { 'nagvis_ini_config':
    name => '/usr/local/nagvis/etc/nagvis.ini.php',
    owner => apache,
    group => apache,
    mode => '0644',
    content => template('nagvis/nagvis.ini.php.erb'),
  }

  # require our own fixed apache config
  file { 'nagvis_httpd_config':
    name => '/etc/httpd/conf.d/nagvis.conf',
    owner => root,
    group => root,
    mode => '0644',
    content => template('nagvis/nagvis.conf.erb'),
    require => Class['apache'],
    notify => Class['apache::service'],
  }

}

