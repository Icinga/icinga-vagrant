# == Class: icingaweb2::config
#
# This class manages general configuration files of Icinga Web 2.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class is private and should not be called by others than this module.
#
class icingaweb2::config {

  $conf_dir             = $::icingaweb2::params::conf_dir
  $conf_user            = $::icingaweb2::conf_user
  $conf_group           = $::icingaweb2::params::conf_group

  $logging              = $::icingaweb2::logging
  $logging_file         = $::icingaweb2::logging_file
  $logging_dir          = dirname($::icingaweb2::logging_file)
  $logging_level        = $::icingaweb2::logging_level
  $show_stacktraces     = $::icingaweb2::show_stacktraces
  $module_path          = $::icingaweb2::module_path

  $theme                = $::icingaweb2::theme
  $theme_disabled       = $::icingaweb2::theme_disabled

  $import_schema        = $::icingaweb2::import_schema
  $schema_dir           = $::icingaweb2::params::schema_dir
  $db_name              = $::icingaweb2::db_name
  $db_host              = $::icingaweb2::db_host
  $db_port              = $::icingaweb2::db_port
  $db_type              = $::icingaweb2::db_type
  $db_username          = $::icingaweb2::db_username
  $db_password          = $::icingaweb2::db_password
  $default_domain       = $::icingaweb2::default_domain

  $config_backend       = $::icingaweb2::config_backend
  $config_resource      = $::icingaweb2::config_backend ? {
    'ini' => undef,
    'db'  => "${db_type}-icingaweb2",
  }

  File {
    mode  => '0660',
    owner => $conf_user,
    group => $conf_group
  }

  Exec {
    user => 'root',
    path => $::path,
  }

  file { $logging_dir:
    ensure => directory,
    mode   => '0750',
  }
  file { $logging_file:
    ensure => file,
    mode   => '0640',
  }

  icingaweb2::inisection {'logging':
    target   => "${conf_dir}/config.ini",
    settings => {
      'log'   => $logging,
      'file'  => $logging_file,
      'level' => $logging_level
    },
  }

  $settings = {
    'show_stacktraces' => $show_stacktraces,
    'module_path'      => $module_path,
    'config_backend'   => $config_backend,
    'config_resource'  => $config_resource,
  }


  icingaweb2::inisection {'global':
    target   => "${conf_dir}/config.ini",
    settings => delete_undef_values($settings),
  }

  if $default_domain {
    icingaweb2::inisection {'authentication':
      target   => "${conf_dir}/config.ini",
      settings => {
        'default_domain' => $default_domain,
      }
    }
  }

  icingaweb2::inisection {'themes':
    target   => "${conf_dir}/config.ini",
    settings => {
      'default'  => $theme,
      'disabled' => $theme_disabled,
    },
  }

  file { "${conf_dir}/modules":
    ensure => 'directory'
  }

  file { "${conf_dir}/enabledModules":
    ensure => 'directory'
  }

  if $import_schema or $config_backend == 'db' {
    icingaweb2::config::resource { "${db_type}-icingaweb2":
      type        => 'db',
      host        => $db_host,
      port        => $db_port,
      db_type     => $db_type,
      db_name     => $db_name,
      db_username => $db_username,
      db_password => $db_password,
    }
  }

  if $import_schema {
    icingaweb2::config::authmethod { "${db_type}-auth":
      backend  => 'db',
      resource => "${db_type}-icingaweb2"
    }

    icingaweb2::config::role { 'default admin user':
      users       => 'icingaadmin',
      permissions => '*',
    }

    icingaweb2::config::groupbackend { "${db_type}-group":
      backend  => 'db',
      resource => "${db_type}-icingaweb2"
    }

    case $db_type {
      'mysql': {
        exec { 'import schema':
          command => "mysql -h '${db_host}' -P '${db_port}' -u '${db_username}' -p'${db_password}' '${db_name}' < '${schema_dir}/mysql.schema.sql'",
          unless  => "mysql -h '${db_host}' -P '${db_port}' -u '${db_username}' -p'${db_password}' '${db_name}' -Ns -e 'SELECT 1 FROM icingaweb_user'",
          notify  => Exec['create default user'],
        }

        exec { 'create default user':
          command     => "mysql -h '${db_host}' -P '${db_port}' -u '${db_username}' -p'${db_password}' '${db_name}' -Ns -e 'INSERT INTO icingaweb_user (name, active, password_hash) VALUES (\"icingaadmin\", 1, \"\$1\$3no6eqZp\$FlcHQDdnxGPqKadmfVcCU.\")'",
          refreshonly => true,
        }
      }
      'pgsql': {
        exec { 'import schema':
          environment => ["PGPASSWORD=${db_password}"],
          command     => "psql -h '${db_host}' -p '${db_port}' -U '${db_username}' -d '${db_name}' -w -f ${schema_dir}/pgsql.schema.sql",
          unless      => "psql -h '${db_host}' -p '${db_port}' -U '${db_username}' -d '${db_name}' -w -c 'SELECT 1 FROM icingaweb_user'",
          notify      => Exec['create default user'],
        }

        exec { 'create default user':
          environment => ["PGPASSWORD=${db_password}"],
          command     => "psql -h '${db_host}' -p '${db_port}' -U '${db_username}' -d '${db_name}' -w -c \"INSERT INTO icingaweb_user(name, active, password_hash) VALUES ('icingaadmin', 1, '\\\$1\\\$3no6eqZp\\\$FlcHQDdnxGPqKadmfVcCU.')\"",
          refreshonly => true,
        }
      }
      default: {
        fail('The database type you provided is not supported.')
      }
    }
  }
}
