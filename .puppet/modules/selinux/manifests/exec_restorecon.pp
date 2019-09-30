# Will execute after all other SELinux changes have been applied, but before
# Anchor['selinux::end']
#
# @summary A convenience wrapper around a restorecon exec
#
# @param path The path to run restorecon on. Defaults to resource title.
# @param recurse Whether restorecon should recurse. Defaults to true
# @param force Whether restorecon should use force.  Defaults to false.
# @param refreshonly see the Exec resource
# @param unless see the Exec resource
# @param onlyif see the Exec resource
#
define selinux::exec_restorecon(
  Stdlib::Absolutepath $path        = $title,
  Boolean              $refreshonly = true,
  Boolean              $recurse     = true,
  Boolean              $force       = false,
  Optional[String]     $unless      = undef,
  Optional[String]     $onlyif      = undef,
) {

  include selinux

  $opt_recurse = $recurse ? {
    true  => ' -R',
    false => '',
  }

  $opt_force = $force ? {
    true  => ' -F',
    false => '',
  }

  $command = "restorecon${opt_force}${opt_recurse}"

  exec {"selinux::exec_restorecon ${path}":
    path        => '/sbin:/usr/sbin',
    command     => sprintf('%s %s', $command, shellquote($path)),
    refreshonly => $refreshonly,
    unless      => $unless,
    onlyif      => $onlyif,
    before      => Anchor['selinux::end'],
  }

  Anchor['selinux::module post']  -> Exec["selinux::exec_restorecon ${path}"]
}
