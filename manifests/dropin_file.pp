# Creates a drop-in file for a systemd unit
#
# @api public
#
# @see systemd.unit(5)
#
# @attr name [Pattern['^.+\.conf$']]
#   The target unit file to create
#
#   * Must not contain ``/``
#
# @attr path
#   The main systemd configuration path
#
# @attr content
#   The full content of the unit file
#
#   * Mutually exclusive with ``$source``
#
# @attr source
#   The ``File`` resource compatible ``source``
#
#   * Mutually exclusive with ``$content``
#
# @attr target
#   If set, will force the file to be a symlink to the given target
#
#   * Mutually exclusive with both ``$source`` and ``$content``
#
# @attr owner
#   The owner to set on the dropin file
#
# @attr group
#   The group to set on the dropin file
#
# @attr mode
#   The mode to set on the dropin file
#
# @attr show_diff
#   Whether to show the diff when updating dropin file
#
# @attr daemon_reload
#   Set to `lazy` to defer execution of a systemctl daemon reload.
#   Minimizes the number of times the daemon is reloaded.
#   Set to `eager` to immediately reload after the dropin file is updated.
#   Useful if the daemon needs to be reloaded before a service is refreshed.
#   May cause multiple daemon reloads.
#
define systemd::dropin_file(
  Systemd::Unit                               $unit,
  Systemd::Dropin                             $filename      = $name,
  Enum['present', 'absent', 'file']           $ensure        = 'present',
  Stdlib::Absolutepath                        $path          = '/etc/systemd/system',
  Optional[Variant[String,Sensitive[String]]] $content       = undef,
  Optional[String]                            $source        = undef,
  Optional[Stdlib::Absolutepath]              $target        = undef,
  String                                      $owner         = 'root',
  String                                      $group         = 'root',
  String                                      $mode          = '0444',
  Boolean                                     $show_diff     = true,
  Enum['lazy', 'eager']                       $daemon_reload = 'lazy',
) {
  include systemd

  if $target {
    $_ensure = 'link'
  } else {
    $_ensure = $ensure ? {
      'present' => 'file',
      default   => $ensure,
    }
  }

  if $ensure != 'absent' {
    ensure_resource('file', "${path}/${unit}.d", {
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      recurse => $::systemd::purge_dropin_dirs,
      purge   => $::systemd::purge_dropin_dirs,
    })
  }

  file { "${path}/${unit}.d/${filename}":
    ensure    => $_ensure,
    content   => $content,
    source    => $source,
    target    => $target,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => $show_diff,
  }

  if $daemon_reload == 'lazy' {
    File["${path}/${unit}.d/${filename}"] ~> Class['systemd::systemctl::daemon_reload']
  } else {
    File["${path}/${unit}.d/${filename}"] ~> Exec["${unit}-systemctl-daemon-reload"]

    exec { "${unit}-systemctl-daemon-reload":
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      path        => $facts['path'],
    }
  }
}
