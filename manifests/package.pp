# selinux::package
#
# THIS IS A PRIVATE CLASS
# =======================
#
# This module manages additional packages required to support some of the functions.
#
# @param manage_package See main class
# @param package_name See main class
#
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
