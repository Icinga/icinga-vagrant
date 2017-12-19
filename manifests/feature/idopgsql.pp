# == Class: icinga2::feature::idopgsql
#
# This module configures the Icinga 2 feature ido-pgsql.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature ido-pgsql, absent disables it. Defaults to present.
#
# [*host*]
#    PostgreSQL database host address. Defaults to '127.0.0.1'.
#
# [*port*]
#    PostgreSQL database port. Defaults to 5432.
#
# [*user*]
#    PostgreSQL database user with read/write permission to the icinga database. Defaults to "icinga".
#
# [*password*]
#    PostgreSQL database user's password. Defaults to "icinga".
#
# [*database*]
#    PostgreSQL database name. Defaults to "icinga".
#
# [*table_prefix*]
#   PostgreSQL database table prefix. Defaults to "icinga_".
#
# [*instance_name*]
#   Unique identifier for the local Icinga 2 instance. Defaults to "default".
#
# [*instance_description*]
#   Description for the Icinga 2 instance.
#
# [*enable_ha*]
#   Enable the high availability functionality. Only valid in a cluster setup. Defaults to "true".
#
# [*failover_timeout*]
#   Set the failover timeout in a HA cluster. Must not be lower than 60s. Defaults to "60s".
#
# [*cleanup*]
#   Hash with items for historical table cleanup.
#
# [*categories*]
#   Array of information types that should be written to the database.
#
# [*import_schema*]
#   Whether to import the PostgreSQL schema or not. Defaults to false.
#
# === Examples
#
# The ido-pgsql featue requires an existing database and a user with permissions.
# To install a database server, create databases and manage user permissions we recommend the puppetlabs-postgresql module.
# Here's an example how you create a PostgreSQL database with the corresponding user with permissions by usng the
# puppetlabs-postgresql module:
#
# include icinga2
# include postgresql::server
#
# postgresql::server::db { 'icinga2':
#   user     => 'icinga2',
#   password => postgresql_password('icinga2', 'supersecret'),
# }
#
# class{ 'icinga2::feature::idopgsql':
#   user          => "icinga2",
#   password      => "supersecret",
#   database      => "icinga2",
#   import_schema => true,
#   require       => Postgresql::Server::Db['icinga2']
# }
#
#
class icinga2::feature::idopgsql(
  $ensure                 = present,
  $host                   = '127.0.0.1',
  $port                   = 5432,
  $user                   = 'icinga',
  $password               = 'icinga',
  $database               = 'icinga',
  $table_prefix           = 'icinga_',
  $instance_name          = 'default',
  $instance_description   = undef,
  $enable_ha              = true,
  $failover_timeout       = '60s',
  $cleanup                = undef,
  $categories             = undef,
  $import_schema          = false,
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $conf_dir             = $::icinga2::params::conf_dir
  $ido_pgsql_package    = $::icinga2::params::ido_pgsql_package
  $ido_pgsql_schema_dir = $::icinga2::params::ido_pgsql_schema_dir
  $manage_package       = $::icinga2::manage_package
  $_notify              = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($host)
  validate_integer($port)
  validate_string($user)
  validate_string($password)
  validate_string($database)
  validate_string($table_prefix)
  validate_string($instance_name)
  if $instance_description { validate_string($instance_description) }
  validate_bool($enable_ha)
  validate_re($failover_timeout, '^\d+[ms]*$')
  if $cleanup { validate_hash($cleanup) }
  if $categories { validate_array($categories) }
  validate_bool($import_schema)

  $attrs = {
    host                  => $host,
    port                  => $port,
    user                  => $user,
    password              => $password,
    database              => $database,
    table_prefix          => $table_prefix,
    instance_name         => $instance_name,
    instance_description  => $instance_description,
    enable_ha             => $enable_ha,
    failover_timeout      => $failover_timeout,
    cleanup               => $cleanup,
    categories            => $categories,
  }

  # install additional package
  if $ido_pgsql_package and $manage_package {
    package { $ido_pgsql_package:
      ensure => installed,
      before => Icinga2::Feature['ido-pgsql'],
    }
    -> class { '::icinga2::debian::dbconfig':
      dbtype   => 'pgsql',
      dbserver => $host,
      dbport   => $port,
      dbname   => $database,
      dbuser   => $user,
      dbpass   => $password,
    }
  }

  # import db schema
  if $import_schema {
    if $ido_pgsql_package and $manage_package {
      Package[$ido_pgsql_package] -> Exec['idopgsql-import-schema']
    }
    exec { 'idopgsql-import-schema':
      user        => 'root',
      path        => $::path,
      environment => ["PGPASSWORD=${password}"],
      command     => "psql -h '${host}' -U '${user}' -d '${database}' -w -f ${ido_pgsql_schema_dir}/pgsql.sql",
      unless      => "psql -h '${host}' -U '${user}' -d '${database}' -w -c 'select version from icinga_dbversion'",
    }
  }

  # create object
  icinga2::object { 'icinga2::object::IdoPgsqlConnection::ido-pgsql':
    object_name => 'ido-pgsql',
    object_type => 'IdoPgsqlConnection',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/ido-pgsql.conf",
    order       => '10',
    notify      => $_notify,
  }

  # import library
  concat::fragment { 'icinga2::feature::ido-pgsql':
    target  => "${conf_dir}/features-available/ido-pgsql.conf",
    content => "library \"db_ido_pgsql\"\n\n",
    order   => '05',
  }

  icinga2::feature { 'ido-pgsql':
    ensure  => $ensure,
  }
}
