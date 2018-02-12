# selinux::permissive
#
# This define will set an SELinux type to permissive
#
# @param ensure Set to present to add or absent to remove a permissive mode of a type
# @param seltype A particular selinux type to make permissive, like "oddjob_mkhomedir_t"
#
# @example Mark oddjob_mkhomedir_t permissive
#   selinux::permissive { 'oddjob_mkhomedir_t':
#     ensure => 'present'
#   }
#
define selinux::permissive (
  String $seltype = $title,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include ::selinux
  if $ensure == 'present' {
    Anchor['selinux::module post']
    -> Selinux::Permissive[$title]
    -> Anchor['selinux::end']
  } else {
    Anchor['selinux::start']
    -> Selinux::Permissive[$title]
    -> Anchor['selinux::module pre']
  }

  selinux_permissive {$seltype:
    ensure => $ensure,
  }
}
