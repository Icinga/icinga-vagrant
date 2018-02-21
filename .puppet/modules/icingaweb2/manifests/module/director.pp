# == Class: icingaweb2::module::director
#
# Install and configure the director module.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*git_repository*]
#   Set a git repository URL. Defaults to github.
#
# [*git_revision*]
#   Set either a branch or a tag name, eg. `master` or `v1.3.2`.
#
# [*db_type*]
#   Type of your database. Either `mysql` or `pgsql`. Defaults to `mysql`
#
# [*db_host*]
#   Hostname of the database.
#
# [*db_port*]
#   Port of the database. Defaults to `3306`
#
# [*db_name*]
#   Name of the database.
#
# [*db_username*]
#   Username for DB connection.
#
# [*db_password*]
#   Password for DB connection.
#
# [*import_schema*]
#   Import database schema. Defaults to `false`
#
# [*kickstart*]
#   Run kickstart command after database migration. This requires `import_schema` to be `true`. Defaults to `false`
#
# [*endpoint*]
#   Endpoint object name of Icinga 2 API. This setting is only valid if `kickstart` is `true`.
#
# [*api_host*]
#   Icinga 2 API hostname. This setting is only valid if `kickstart` is `true`. Defaults to `localhost`
#
# [*api_port*]
#   Icinga 2 API port. This setting is only valid if `kickstart` is `true`. Defaults to `5665`
#
# [*api_username*]
#   Icinga 2 API username. This setting is only valid if `kickstart` is `true`.
#
# [*api_password*]
#   Icinga 2 API password. This setting is only valid if `kickstart` is `true`.
#
class icingaweb2::module::director(
  Enum['absent', 'present'] $ensure         = 'present',
  String                    $git_repository = 'https://github.com/Icinga/icingaweb2-module-director.git',
  Optional[String]          $git_revision   = undef,
  Enum['mysql', 'pgsql']    $db_type        = 'mysql',
  Optional[String]          $db_host        = undef,
  Integer[1,65535]          $db_port        = 3306,
  Optional[String]          $db_name        = undef,
  Optional[String]          $db_username    = undef,
  Optional[String]          $db_password    = undef,
  Optional[Boolean]         $import_schema  = false,
  Optional[Boolean]         $kickstart      = false,
  Optional[String]          $endpoint       = undef,
  String                    $api_host       = 'localhost',
  Integer[1,65535]          $api_port       = 5665,
  Optional[String]          $api_username   = undef,
  Optional[String]          $api_password   = undef,
){
  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/director"

  Exec {
    user => 'root',
    path => $::path,
  }

  icingaweb2::config::resource { 'icingaweb2-module-director':
    type        => 'db',
    db_type     => $db_type,
    host        => $db_host,
    port        => $db_port,
    db_name     => $db_name,
    db_username => $db_username,
    db_password => $db_password,
    db_charset  => 'utf8',
  }

  $db_settings = {
    'module-director-db' => {
      'section_name' => 'db',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => {
        'resource'   => 'icingaweb2-module-director'
      }
    }
  }

  if $import_schema {
    ensure_packages(['icingacli'], { 'ensure' => 'present' })

    exec { 'director-migration':
      command => 'icingacli director migration run',
      onlyif  => 'icingacli director migration pending',
      require => [ Package['icingacli'], Icingaweb2::Module['director'] ]
    }

    if $kickstart {
      $kickstart_settings = {
        'module-director-config' => {
          'section_name' => 'config',
          'target'       => "${module_conf_dir}/kickstart.ini",
          'settings'     => {
            'endpoint'   => $endpoint,
            'host'       => $api_host,
            'port'       => $api_port,
            'username'   => $api_username,
            'password'   => $api_password,
          }
        }
      }

      exec { 'director-kickstart':
        command => 'icingacli director kickstart run',
        onlyif  => 'icingacli director kickstart required',
        require => Exec['director-migration']
      }
    } else {
      $kickstart_settings = {}
    }
  } else {
    $kickstart_settings = {}
  }

  icingaweb2::module {'director':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
    settings       => merge($db_settings, $kickstart_settings),
  }
}
