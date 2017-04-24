# Class: selinux
#
# This class manages SELinux on RHEL based systems.
#
# @example Enable enforcing mode with targeted policy
#   class { 'selinux':
#     mode => 'enforcing',
#     type => 'targeted',
#   }
#
# @param mode sets the operating state for SELinux.
#   Default value: undef
#   Allowed values: (enforcing|permissive|disabled|undef)
# @param type sets the selinux type
#   Default value: undef
#   Allowed values: (targeted|minimum|mls|undef)
# @param sx_mod_dir directory where to store puppet managed selinux modules
#   Default value: /usr/share/selinux
#   Allowed values: absolute path
# @param makefile the path to the systems SELinux makefile
#   Default value: /usr/share/selinux/devel/Makefile
#   Allowed value: absolute path
# @param manage_package manage the package for selinux tools
#   Default value: true
# @param package_name sets the name for the selinux tools package
#   Default value: OS dependent (see params.pp)
# @param boolean Hash of selinux::boolean resource parameters
# @param fcontext Hash of selinux::fcontext resource parameters
# @param module Hash of selinux::module resource parameters
# @param permissive Hash of selinux::module resource parameters
# @param port Hash of selinux::port resource parameters
#
class selinux (
  $mode           = $::selinux::params::mode,
  $type           = $::selinux::params::type,
  $sx_mod_dir     = $::selinux::params::sx_mod_dir,
  $makefile       = $::selinux::params::makefile,
  $manage_package = $::selinux::params::manage_package,
  $package_name   = $::selinux::params::package_name,

  ### START Hiera Lookups ###
  $boolean        = undef,
  $fcontext       = undef,
  $module         = undef,
  $permissive     = undef,
  $port           = undef,
  ### END Hiera Lookups ###

) inherits selinux::params {

  $mode_real = $mode ? {
    /\w+/   => $mode,
    default => 'undef',
  }

  $type_real = $type ? {
    /\w+/   => $type,
    default => 'undef',
  }

  validate_absolute_path($sx_mod_dir)
  validate_re($mode_real, ['^enforcing$', '^permissive$', '^disabled$', '^undef$'], "Valid modes are enforcing, permissive, and disabled.  Received: ${mode}")
  validate_re($type_real, ['^targeted$', '^minimum$', '^mls$', '^undef$'], "Valid types are targeted, minimum, and mls.  Received: ${type}")
  validate_string($makefile)
  validate_bool($manage_package)
  validate_string($package_name)

  class { '::selinux::package':
    manage_package => $manage_package,
    package_name   => $package_name,
  } ->
  class { '::selinux::config': }

  if $boolean {
    create_resources ( 'selinux::boolean', hiera_hash('selinux::boolean') )
  }
  if $fcontext {
    create_resources ( 'selinux::fcontext', hiera_hash('selinux::fcontext') )
  }
  if $module {
    create_resources ( 'selinux::module', hiera_hash('selinux::module') )
  }
  if $permissive {
    create_resources ( 'selinux::fcontext', hiera_hash('selinux::permissive') )
  }
  if $port {
    create_resources ( 'selinux::port', hiera_hash('selinux::port') )
  }
}
