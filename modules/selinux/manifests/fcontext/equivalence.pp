# selinux::fcontext::equivalence
#
# This define can be used to manage SELinux fcontext equivalences
#
# @param path   the path to define and equivalence for. Default: Resource title
# @param target the path that this resource will be equivalent to.
# @param ensure the desired state of the equivalence. Default: present
#
# @example Make /opt/wordpress equivalent to /usr/share/wordpress
#   selinux::fcontext::equivalence { '/opt/wordpress':
#     ensure => 'present',
#     target => '/usr/share/wordpress',
#   }
#
define selinux::fcontext::equivalence(
  String $target,
  String $path = $title,
  Enum['present', 'absent'] $ensure = 'present'
) {

  include ::selinux

  if $ensure == 'present' {
    Anchor['selinux::module post']
    -> Selinux::Fcontext::Equivalence[$title]
    -> Anchor['selinux::end']
  } else {
    Anchor['selinux::start']
    -> Selinux::Fcontext::Equivalence[$title]
    -> Anchor['selinux::module pre']
  }

  selinux_fcontext_equivalence { $path:
    ensure => $ensure,
    target => $target,
  }
}

