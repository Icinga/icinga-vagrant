# == Define: icingaweb2::config::resource
#
# Create and remove Icinga Web 2 resources. Resources may be referenced in other configuration sections.
#
# === Parameters
#
# [*resource_name*]
#   Name of the resources. Resources are referenced by their name in other configuration sections.
#
# [*type*]
#   Supported resource types are `db` and `ldap`.
#
# [*host*]
#   Connect to the database or ldap server on the given host. For using unix domain sockets, specify 'localhost' for
#   MySQL and the path to the unix domain socket directory for PostgreSQL. When using the 'ldap' type you can also
#   provide multiple hosts separated by a space.
#
# [*port*]
#   Port number to use.
#
# [*db_type*]
#   Supported DB types are `mysql` and `pgsql`.
#
# [*db_name*]
#   The database to use. Only valid if `type` is `db`.
#
# [*db_username*]
#   The username to use when connecting to the server. Only valid if `type` is `db`.
#
# [*db_password*]
#   The password to use when connecting to the server. Only valid if `type` is `db`.
#
# [*db_charset*]
#   The character set to use for the database connection. Only valid if `type` is `db`.
#
# [*ldap_root_dn*]
#   Root object of the tree, e.g. 'ou=people,dc=icinga,dc=com'. Only valid if `type` is `ldap`.
#
# [*ldap_bind_dn*]
#   The user to use when connecting to the server. Only valid if `type` is `ldap`.
#
# [*ldap_bind_pw*]
#   The password to use when connecting to the server. Only valid if `type` is `ldap`.
#
# [*ldap_encryption*]
#   Type of encryption to use: none (default), starttls, ldaps. Only valid if `type` is `ldap`.
#
# === Examples
#
# Create a 'db' resource:
#
# icingaweb2::config::resource{'my-sql':
#   type        => 'db',
#   db_type     => 'mysql',
#   host        => 'localhost',
#   port        => '3306',
#   db_name     => 'icingaweb2',
#   db_username => 'root',
#   db_password => 'supersecret',
# }
#
#
define icingaweb2::config::resource(
  String                                      $resource_name   = $title,
  Enum['db', 'ldap']                          $type            = undef,
  String                                      $host            = undef,
  Integer[1,65535]                            $port            = undef,
  Optional[Enum['mysql', 'pgsql']]            $db_type         = undef,
  Optional[String]                            $db_name         = undef,
  Optional[String]                            $db_username     = undef,
  Optional[String]                            $db_password     = undef,
  Optional[String]                            $db_charset      = undef,
  Optional[String]                            $ldap_root_dn    = undef,
  Optional[String]                            $ldap_bind_dn    = undef,
  Optional[String]                            $ldap_bind_pw    = undef,
  Optional[Enum['none', 'starttls', 'ldaps']] $ldap_encryption = 'none',
) {

  $conf_dir = $::icingaweb2::params::conf_dir

  case $type {
    'db': {
      $settings = {
        'type'     => $type,
        'db'       => $db_type,
        'host'     => $host,
        'port'     => $port,
        'dbname'   => $db_name,
        'username' => $db_username,
        'password' => $db_password,
        'charset'  => $db_charset,
      }
    }
    'ldap': {
      $settings = {
        'type'       => $type,
        'hostname'   => $host,
        'port'       => $port,
        'root_dn'    => $ldap_root_dn,
        'bind_dn'    => $ldap_bind_dn,
        'bind_pw'    => $ldap_bind_pw,
        'encryption' => $ldap_encryption,
      }
    }
    default: {
      fail('The resource type you provided is not supported.')
    }
  }

  icingaweb2::inisection { $resource_name:
    target   => "${conf_dir}/resources.ini",
    settings => delete_undef_values($settings),
  }
}
