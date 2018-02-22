# == Class: icinga2::debian::dbconfig
#
class icinga2::debian::dbconfig(
  $dbtype,
  $dbserver,
  $dbport,
  $dbname,
  $dbuser,
  $dbpass,
  $ssl = false,
) {

  assert_private()

  validate_re($dbtype, [ '^mysql$', '^pgsql$' ],
    "${dbtype} isn't supported. Valid values are 'mysql' and 'pgsql'.")
  validate_string($dbserver)
  validate_integer($dbport)
  validate_string($dbname)
  validate_string($dbuser)
  validate_string($dbpass)
  validate_bool($ssl)

  # dbconfig config for Debian or Ubuntu
  if $::osfamily == 'debian' {

      include ::icinga2::params

      case $dbtype {
        'mysql': {
          $default_port = 3306
          $path         = "/etc/dbconfig-common/${::icinga2::params::ido_mysql_package}.conf"
        }
        'pgsql': {
          $default_port = 5432
          $path         = "/etc/dbconfig-common/${::icinga2::params::ido_pgsql_package}.conf"
        }
        default: {
          fail("Unsupported dbtype: ${dbtype}")
        }
      }

      file_line { "dbc-${dbtype}-dbuser":
        path  => $path,
        line  => "dbc_dbuser='${dbuser}'",
        match => '^dbc_dbuser\s*=',
      }
      file_line { "dbc-${dbtype}-dbpass":
        path  => $path,
        line  => "dbc_dbpass='${dbpass}'",
        match => '^dbc_dbpass\s*=',
      }
      file_line { "dbc-${dbtype}-dbname":
        path  => $path,
        line  => "dbc_dbname='${dbname}'",
        match => '^dbc_dbname\s*=',
      }
      # only set host if isn't the default
      if $dbserver != '127.0.0.1' and $dbserver != 'localhost' {
        file_line { "dbc-${dbtype}-dbserver":
          path  => $path,
          line  => "dbc_dbserver='${dbserver}'",
          match => '^dbc_dbserver\s*=',
        }
      }
      # only set port if isn't the default
      if $dbport != $default_port {
        file_line { "dbc-${dbtype}-dbport":
          path  => $path,
          line  => "dbc_dbport='${dbport}'",
          match => '^dbc_dbport\s*=',
        }
      }
      # set ssl
      if $ssl {
        file_line { "dbc-${dbtype}-ssl":
          path  => $path,
          line  => "dbc_ssl='true'",
          match => '^dbc_ssl\s*=',
        }
      }
  } # debian dbconfig
}
