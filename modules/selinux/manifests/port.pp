# selinux::port
#
# This method will manage a local network port context setting, and will
# persist it across reboots.
#
# @example Add port-context syslogd_port_t to port 8514/tcp
#   selinux::port { 'allow-syslog-relp':
#     ensure   => 'present',
#     seltype  => 'syslogd_port_t',
#     protocol => 'tcp',
#     port     => 8514,
#   }
#
# @param ensure Set to present to add or absent to remove a port context.
# @param seltype An SELinux port type
# @param protocol Either 'tcp', 'udp', 'ipv4' or 'ipv6'
# @param port A network port number, like 8514,
# @param port_range A port-range tuple, eg. [9090, 9095].
#
define selinux::port (
  String                             $seltype,
  Enum['tcp', 'udp']                 $protocol,
  Optional[Integer[1,65535]]         $port = undef,
  Optional[Tuple[Integer[1,65535], 2, 2]] $port_range = undef,
  Enum['present', 'absent']          $ensure = 'present',
) {

  include ::selinux

  if $ensure == 'present' {
    Anchor['selinux::module post']
    -> Selinux::Port[$title]
    -> Anchor['selinux::end']
  } elsif $ensure == 'absent' {
    Class['selinux::config']
    -> Selinux::Port[$title]
    -> Anchor['selinux::module pre']
  } else {
    fail('Unexpected $ensure value')
  }

  if ($port == undef and $port_range == undef) {
    fail("You must define either 'port' or 'port_range'")
  }
  if ($port != undef and $port_range != undef) {
    fail("You can't define both 'port' and 'port_range'")
  }

  $range = $port_range ? {
    undef   => [$port, $port],
    default => $port_range,
  }

  # this can only happen if port_range is used
  if $range[0] > $range[1] {
    fail("Malformed port range: ${port_range}")
  }

  selinux_port {"${protocol}_${range[0]}-${range[1]}":
    ensure    => $ensure,
    low_port  => $range[0],
    high_port => $range[1],
    seltype   => $seltype,
    protocol  => $protocol,
  }
}
