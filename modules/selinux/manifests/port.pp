# Definition: selinux::fcontext
#
# Description
#  This method will manage a local network port context setting, and will
#  persist it across reboots.
#  It will perform a check to ensure the network context is not already set.
#  Anyplace you wish to use this method you must ensure that the selinux class is required
#  first. Otherwise you run the risk of attempting to execute the semanage and that program
#  will not yet be installed.
#
# Class create by Matt Willsher<matt@monki.org.uk>
# Based on selinux::fcontext by Erik M Jacobs<erikmjacobs@gmail.com>
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#  Originally written/sourced from Lance Dillon<>
#   http://riffraff169.wordpress.com/2012/03/09/add-file-contexts-with-puppet/
#
# Parameters:
#   - $context: A particular network port context, like "syslogd_port_t"
#   - $protocol: Either tcp or udp. If unset, omits -p flag from semanage.
#   - $port: An network port number, like '8514'
#   - $argument: An argument for semanage port. Default: "-a"
#
# Actions:
#  Runs "semanage port" with options to persistently set the file context
#
# Requires:
#  - SELinux
#  - policycoreutils-python (for el-based systems)
#
# Sample Usage:
#
#  selinux::port { 'allow-syslog-relp':
#    context  => 'syslogd_port_t',
#    protocol => 'tcp',
#    port     => '8514',
#  }
#
define selinux::port (
  $context,
  $port,
  $protocol = undef,
  $argument = '-a',
) {

  include ::selinux

  if $protocol {
    validate_re($protocol, ['^tcp6?$', '^udp6?$'])
    $protocol_switch = ['-p', $protocol]
    $protocol_check = "${protocol} "
    $port_exec_command = "add_${context}_${port}_${protocol}"
  } else {
    $protocol_switch = []
    $protocol_check = '' # lint:ignore:empty_string_assignment variable is used to create regexp and undef is not possible
    $port_exec_command = "add_${context}_${port}"
  }

  exec { $port_exec_command:
    command => shellquote('semanage', 'port', $argument, '-t', $context, $protocol_switch, "${port}"), # lint:ignore:only_variable_string port can be number and we need to force it to be string for shellquote
    # This works because there seems to be more than one space after protocol and before first port
    unless  => sprintf('semanage port -l | grep -E %s', shellquote("^${context}  *${protocol_check}.* ${port}(\$|,)")),
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
