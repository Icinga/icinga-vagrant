# Definition: selinux::permissive
#
# Description
#  This method will set a context to permissive
#
# Class create by David Twersky <dmtwersky@gmail.com>
# Based on selinux::fcontext by Erik M Jacobs<erikmjacobs@gmail.com>
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#  Originally written/sourced from Lance Dillon<>
#   http://riffraff169.wordpress.com/2012/03/09/add-file-contexts-with-puppet/
#
# Parameters:
#   - $context: A particular context, like "oddjob_mkhomedir_t"
#
# Actions:
#  Runs "semanage permissive -a" with the context you wish to allow
#
# Requires:
#  - SELinux
#  - policycoreutils-python (for el-based systems)
#
# Sample Usage:
#
#  selinux::permissive { 'allow-oddjob_mkhomedir_t':
#    context  => 'oddjob_mkhomedir_t',
#  }
#
define selinux::permissive (
  $context,
) {

  include ::selinux

  exec { "add_${context}":
    command => shellquote('semanage', 'permissive', '-a', $context),
    unless  => sprintf('semanage permissive -l | grep -Fx %s', shellquote($context)),
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
