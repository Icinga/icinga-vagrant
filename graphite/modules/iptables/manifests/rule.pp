define iptables::rule (
  $tcp = undef,
  $udp = undef
) {
  include iptables
  $port = $title
  if $tcp {
    case $tcp {
      'allow': { iptables::allow{ "tcp/${port}": port => $port, protocol => 'tcp' } }
      'drop':  { iptables::drop{  "tcp/${port}": port => $port, protocol => 'tcp' } }
      default: {
        fail("iptables: unknown action '${tcp}' - use 'allow' or 'drop'")
      }
    }
  }
  if $udp {
    case $udp {
      'allow': { iptables::allow{ "udp/${port}": port => $port, protocol => 'udp' } }
      'drop':  { iptables::drop{  "udp/${port}": port => $port, protocol => 'udp' } }
      default: {
        fail("iptables: unknown action '${udp}' - use 'allow' or 'drop'")
      }
    }
  }
}
