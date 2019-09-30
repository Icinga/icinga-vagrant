# Adds a set of custom limits to the service
#
# @api public
#
# @see systemd.exec(5)
#
# @attr name [Pattern['^.+\.(service|socket|mount|swap)$']]
#   The name of the service that you will be modifying
#
# @param $ensure
#   Whether to drop a file or remove it
#
# @param path
#   The path to the main systemd settings directory
#
# @param limits
#   A Hash of service limits matching the settings in ``systemd.exec(5)``
#
#   * Mutually exclusive with ``$source``
#
# @param source
#   A ``File`` resource compatible ``source``
#
#  * Mutually exclusive with ``$limits``
#
# @param restart_service
#   Restart the managed service after setting the limits
#
define systemd::service_limits(
  Enum['present', 'absent', 'file'] $ensure          = 'present',
  Stdlib::Absolutepath              $path            = '/etc/systemd/system',
  Optional[Systemd::ServiceLimits]  $limits          = undef,
  Optional[String]                  $source          = undef,
  Boolean                           $restart_service = true
) {

  include systemd

  if $name !~ Pattern['^.+\.(service|socket|mount|swap)$'] {
    fail('$name must match Pattern["^.+\.(service|socket|mount|swap)$"]')
  }

  if $limits and !empty($limits) {
    $_content = template("${module_name}/limits.erb")
  }
  else {
    $_content = undef
  }

  if $ensure != 'absent' {
    if ($limits and !empty($limits)) and $source {
      fail('You may not supply both limits and source parameters to systemd::service_limits')
    }
    elsif ($limits == undef or empty($limits)) and ($source == undef) {
      fail('You must supply either the limits or source parameter to systemd::service_limits')
    }
  }

  systemd::dropin_file { "${name}-90-limits.conf":
    ensure   => $ensure,
    unit     => $name,
    filename => '90-limits.conf',
    path     => $path,
    content  => $_content,
    source   => $source,
  }

  if $restart_service {
    exec { "restart ${name} because limits":
      command     => "systemctl restart ${name}",
      path        => $::path,
      refreshonly => true,
      subscribe   => File["${path}/${name}.d/90-limits.conf"],
      require     => Class['systemd::systemctl::daemon_reload'],
    }
  }
}
