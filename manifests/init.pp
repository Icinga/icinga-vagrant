# Manage SELinux on RHEL based systems.
#
# @example Enable enforcing mode with targeted policy
#   class { 'selinux':
#     mode => 'enforcing',
#     type => 'targeted',
#   }
#
# @param mode sets the operating state for SELinux.
# @param type sets the selinux type
# @param refpolicy_makefile the path to the system's SELinux makefile for the refpolicy framework
# @param manage_package manage the package for selinux tools and refpolicy
# @param package_name sets the name for the selinux tools package
#   Default value: OS dependent (see params.pp)
# @param refpolicy_package_name sets the name for the refpolicy development package, required for the
#   refpolicy module builder
#   Default value: OS dependent (see params.pp)
# @param module_build_root directory where modules are built. Defaults to `$vardir/puppet-selinux`
# @param default_builder which builder to use by default with selinux::module
# @param boolean Hash of selinux::boolean resource parameters
# @param fcontext Hash of selinux::fcontext resource parameters
# @param module Hash of selinux::module resource parameters
# @param permissive Hash of selinux::module resource parameters
# @param port Hash of selinux::port resource parameters
# @param exec_restorecon Hash of selinux::exec_restorecon resource parameters
#
class selinux (
  Optional[Enum['enforcing', 'permissive', 'disabled']] $mode = undef,
  Optional[Enum['targeted', 'minimum', 'mls']] $type          = undef,
  Stdlib::Absolutepath $refpolicy_makefile                    = '/usr/share/selinux/devel/Makefile',
  Boolean $manage_package                                     = true,
  String $package_name                                        = $selinux::params::package_name,
  String $refpolicy_package_name                              = 'selinux-policy-devel',
  Stdlib::Absolutepath $module_build_root                     = $selinux::params::module_build_root,
  Enum['refpolicy', 'simple'] $default_builder                = 'simple',

  ### START Hiera Lookups ###
  Optional[Hash] $boolean         = undef,
  Optional[Hash] $fcontext        = undef,
  Optional[Hash] $module          = undef,
  Optional[Hash] $permissive      = undef,
  Optional[Hash] $port            = undef,
  Optional[Hash] $exec_restorecon = undef,
  ### END Hiera Lookups ###

) inherits selinux::params {

  class { 'selinux::package':
    manage_package => $manage_package,
    package_name   => $package_name,
  }

  class { 'selinux::config': }

  if $boolean {
    create_resources ( 'selinux::boolean', $boolean )
  }
  if $fcontext {
    create_resources ( 'selinux::fcontext', $fcontext )
  }
  if $module {
    create_resources ( 'selinux::module', $module )
  }
  if $permissive {
    create_resources ( 'selinux::permissive', $permissive )
  }
  if $port {
    create_resources ( 'selinux::port', $port )
  }
  if $exec_restorecon {
    create_resources ( 'selinux::exec_restorecon', $exec_restorecon )
  }

  # Ordering
  anchor { 'selinux::start': }
  -> Class['selinux::package']
  -> Class['selinux::config']
  -> anchor { 'selinux::module pre': }
  -> anchor { 'selinux::module post': }
  -> anchor { 'selinux::end': }
}
