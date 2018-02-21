# == Define: icingaweb2::config::resource
#
# Roles define a set of permissions that may be applied to users or groups.
#
# === Parameters
#
# [*role_name*]
#   Name of the role.
#
# [*users*]
#   Comma separated list of users this role applies to.
#
# [*groups*]
#   Comma separated list of groups this role applies to.
#
# [*permissions*]
#   Comma separated lsit of permissions. Each module may add it's own permissions. Examples are
#   - Allow everything: '*'
#   - Allow config access: 'config/*'
#   - Allow access do module monitoring: 'module/monitoring'
#   - Allow scheduling checks: 'monitoring/command/schedule-checks'
#   - Grant admin permissions: 'admin'
#
# [*filters*]
#   Hash of filters. Modules may add new filter keys, some sample keys are:
#   - application/share/users
#   - application/share/groups
#   - monitoring/filter/objects
#   - monitoring/blacklist/properties
#   A string value is expected for each used key. For example:
#   - monitoring/filter/objects = "host_name!=*win*"
#
# === Examples
#
# Create role that allows only hosts beginning with 'linux-*':
#
# icingaweb2::config::role{'linux-user':
#   groups      => 'linuxer',
#   permissions => '*',
#   filters     => {
#     'monitoring/filter/objects' => 'host_name=linux-*'
#   }
# }
#
define icingaweb2::config::role(
  String           $role_name   = $title,
  Optional[String] $users       = undef,
  Optional[String] $groups      = undef,
  Optional[String] $permissions = undef,
  Hash             $filters     = {},
) {

  $conf_dir = $::icingaweb2::params::conf_dir

  $settings = {
    'users'       => $users,
    'groups'      => $groups,
    'permissions' => $permissions,
  }

  icingaweb2::inisection{ $role_name:
    target   => "${conf_dir}/roles.ini",
    settings => delete_undef_values(merge($settings,$filters))
  }
}
