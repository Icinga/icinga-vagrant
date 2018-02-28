# == Class: icingaweb2::module::graphite
#
# The Graphite module draws graphs out of time series data stored in Graphite.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*url*]
#   URL to your Graphite Web
#
# [*user*]
#   A user with access to your Graphite Web via HTTP basic authentication
#
# [*password*]
#   The users password
#
# [*graphite_writer_host_name_template*]
#    The value of your Icinga 2 GraphiteWriter's attribute `host_name_template` (if specified)
#
# [*graphite_writer_service_name_template*]
#   The value of your icinga 2 GraphiteWriter's attribute `service_name_template` (if specified)
#
class icingaweb2::module::graphite(
  Enum['absent', 'present'] $ensure                                = 'present',
  String                    $git_repository                        = 'https://github.com/Icinga/icingaweb2-module-graphite.git',
  Optional[String]          $git_revision                          = undef,
  String                    $url                                   = undef,
  Optional[String]          $user                                  = undef,
  Optional[String]          $password                              = undef,
  Optional[String]          $graphite_writer_host_name_template    = undef,
  Optional[String]          $graphite_writer_service_name_template = undef
){

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/graphite"

  $graphite_settings = {
    'url'      => $url,
    'user'     => $user,
    'password' => $password,
  }

  $icinga_settings = {
    'graphite_writer_host_name_template'    => $graphite_writer_host_name_template,
    'graphite_writer_service_name_template' => $graphite_writer_service_name_template,
  }

  $settings = {
    'module-graphite-graphite' => {
      'section_name' => 'graphite',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($graphite_settings)
    },
    'module-graphite-icinga' => {
      'section_name' => 'icinga',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($icinga_settings)
    }
  }

  icingaweb2::module { 'graphite':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
    settings       => $settings,
  }
}