# Defined type: selinux::module
#
# This class will either install or uninstall a SELinux module from a running system.
# This module allows an admin to keep .te files in text form in a repository, while
# allowing the system to compile and manage SELinux modules.
#
# Concepts incorporated from:
# http://stuckinadoloop.wordpress.com/2011/06/15/puppet-managed-deployment-of-selinux-modules/
# 
# @example compile and load the apache module
#   selinux::module{ 'apache':
#     ensure => 'present',
#     source => 'puppet:///modules/selinux/apache.te',
#   }
#
# @param ensure present or absent
# @param sx_mod_dir path where source is stored and the module built. 
#   Valid values: absolute path
# @param source the source file (either a puppet URI or local file) of the SELinux .te file
# @param content content of the source .te file
# @param makefile absolute path to the selinux-devel Makefile
# @param prefix (DEPRECATED) the prefix to add to the loaded module. Defaults to ''.
#   Does not work with CentOS >= 7.2 and Fedora >= 24 SELinux tools.
# @param syncversion selmodule syncversion param
define selinux::module(
  $source       = undef,
  $content      = undef,
  $ensure       = 'present',
  $makefile     = '/usr/share/selinux/devel/Makefile',
  $prefix       = '',
  $sx_mod_dir   = '/usr/share/selinux',
  $syncversion  = undef,
) {

  include ::selinux

  validate_re($ensure, [ '^present$', '^absent$' ], '$ensure must be "present" or "absent"')
  if $ensure == 'present' and $source == undef and $content == undef {
    fail("You must provide 'source' or 'content' field for selinux module")
  }
  if $source != undef {
    validate_string($source)
  }
  if $content != undef {
    validate_string($content)
  }
  validate_string($prefix)
  validate_absolute_path($sx_mod_dir)
  validate_absolute_path($makefile)
  if $syncversion != undef {
    validate_bool($syncversion)
  }

  ## Begin Configuration
  file { "${sx_mod_dir}/${prefix}${name}.te":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $source,
    content => $content,
  }
  ~>
  exec { "${sx_mod_dir}/${prefix}${name}.pp":
  # Only allow refresh in the event that the initial .te file is updated.
    command     => shellquote('make', '-f', $makefile, "${prefix}${name}.pp"),
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    refreshonly => true,
    cwd         => $sx_mod_dir,
  }
  ->
  selmodule { $name:
    # Load the module if it has changed or was not loaded
    # Warning: change the .te version!
    ensure        => $ensure,
    selmodulepath => "${sx_mod_dir}/${prefix}${name}.pp",
    syncversion   => $syncversion,
  }
}
