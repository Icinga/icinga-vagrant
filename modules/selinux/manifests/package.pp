# Class: selinux::package
#
# This module manages additional packages required to support some of the functions.
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class selinux::package (
  $manage_package = $::selinux::manage_package,
  $package_name   = $::selinux::package_name,
){
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  if $manage_package {
    ensure_packages ($package_name)
  }
}
