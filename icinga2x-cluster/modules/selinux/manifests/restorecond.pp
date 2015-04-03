#
# Class selinux::restorecond
#
class selinux::restorecond (
  $config_file       = $selinux::params::restorecond_config_file,
  $config_file_mode  = $selinux::params::restorecond_config_file_mode,
  $config_file_owner = $selinux::params::restorecond_config_file_owner,
  $config_file_group = $selinux::params::restorecond_config_file_group,
) inherits selinux::params {
  class{'selinux::restorecond::install':} ->
  class{'selinux::restorecond::config':} ~>
  class{'selinux::restorecond::service':}
}
