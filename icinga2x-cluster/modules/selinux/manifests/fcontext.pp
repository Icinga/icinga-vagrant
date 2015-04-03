# Definition: selinux::fcontext
#
# Description
#  This method will manage a local file context setting, and will persist it across reboots.
#  It will perform a check to ensure the file context is not already set.
#  Anyplace you wish to use this method you must ensure that the selinux class is required
#  first. Otherwise you run the risk of attempting to execute the semanage and that program
#  will not yet be installed.
#
# Class created by Erik M Jacobs<erikmjacobs@gmail.com>
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#  Originally written/sourced from Lance Dillon<>
#   http://riffraff169.wordpress.com/2012/03/09/add-file-contexts-with-puppet/
#
# Parameters:
#   - $context: A particular file context, like "mysqld_log_t"
#   - $pathname: An semanage fcontext-formatted pathname, like "/var/log/mysql(/.*)?"
#
# Actions:
#  Runs "semanage fcontext" with options to persistently set the file context
#
# Requires:
#  - SELinux
#  - policycoreutils-python (for el-based systems)
#
# Sample Usage:
#
# selinux::fcontext{'set-mysql-log-context':
#   context => "mysqld_log_t",
#   pathname => "/var/log/mysql(/.*)?",
# }
#
# selinux::fcontext{'set-postfix-instance1-spool':
#   equals      => true,
#   pathname    => '/var/spool/postfix-instance1',
#   destination => '/var/spool/postfix'
# }
#
define selinux::fcontext (
  $context     = '',
  $pathname    = '',
  $policy      = 'targeted',
  $equals      = false,
  $destination = '',
) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $pathname == '' {
    fail('pathname must not be empty')
  }

  if ( $equals == false ) and ( $pathname == '' ) {
    fail('pathname must not be empty')
  }

  if ( $equals == true ) and ( $destination == '' ) {
    fail('destination must be set if equals is true')
  }

  if $equals == true {
    $command = "semanage fcontext -a -e \"${destination}\" \"${pathname}\""
    $unless  = "semanage fcontext -l | grep \"^${pathname} = ${destination}$\""
  } else {
    $command = "semanage fcontext -a -t ${context} \"${pathname}\""
    $unless  = "semanage fcontext -l | grep \"^${pathname}.*:${context}:\""
  }

  exec { "add_${context}_${pathname}":
    command => $command,
    unless  => $unless,
    require => Class['selinux::package'],
  }
}
