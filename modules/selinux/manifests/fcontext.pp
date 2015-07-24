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
#  Modified on 1/8/2015 by jeremy.grant@outlook.com
#   added support for file type parameter in semanage fcontext
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#  Originally written/sourced from Lance Dillon<>
#   http://riffraff169.wordpress.com/2012/03/09/add-file-contexts-with-puppet/
#
# Parameters:
#   - $context: A particular file context, like "mysqld_log_t"
#   - $pathname: An semanage fcontext-formatted pathname, like "/var/log/mysql(/.*)?"
#   - $equals:   Boolean Value - Enables support for substituting target path with sourcepath when generating default label
#   - $filetype: Boolean Value - enables support for "-f" file type option of "semanage fcontext"
#   - $filemode: File Mode for policy (i.e. regular file, directory, block device, all files, etc.)
#       - Types:
#         - a = all files (default value if not restricting filetype)
#         - f = regular file
#         - d = directory
#         - c = character device
#         - b = block device
#         - s = socket
#         - l = symbolic link
#         - p = named pipe
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
# FOR SUBSTITUTING TARGET PATH WITH SOURCEPATH:
# selinux::fcontext{'set-postfix-instance1-spool':
#   equals      => true,
#   pathname    => '/var/spool/postfix-instance1',
#   destination => '/var/spool/postfix'
# }
#
# FOR SETTING CONTEXT TYPE - WITHOUT SPECIFYING FILETYPE:
# THIS WILL APPLY THE DEFAULT 'ALL FILES' FILETYPE
# selinux::fcontext{'set-mysql-log-context':
#   context => "mysqld_log_t",
#   pathname => "/var/log/mysql(/.*)?",
# }
#
# FOR SETTING CONTEXT TYPE - WITH FILETYPE SPECIFIED (i.e. - policy applies only to directories, files, etc.)
# selinux::fcontext{'set-non-home-user-dir_type_d':
#   filetype => true ,
#   filemode => 'd' ,
#   context  => 'user_home_dir_t' ,
#   pathname => '/u/users/[^/]*' ,
# }
#
define selinux::fcontext (
  $pathname,
  $destination = undef,
  $context     = '',
  $filetype    = false,
  $filemode    = undef,
  $equals      = false,
) {

  include selinux

  validate_absolute_path($pathname)
  validate_bool($filetype, $equals)

  if $equals {
    validate_absolute_path($destination)
  }

  if $equals and $filetype {
    fail('Resource cannot contain both "equals" and "filetype" options')
  }

  if $filetype and $filemode !~ /(a|f|d|c|b|s|l|p)/ {
    fail('file mode must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
  }

  if $equals {
    $resource_name = "add_${destination}_${pathname}"
    $command       = "semanage fcontext -a -e \"${destination}\" \"${pathname}\""
    $unless        = "semanage fcontext -l | grep -E \"^${pathname} = ${destination}$\""
  } elsif $filetype {
    $resource_name = "add_${context}_${pathname}_type_${filemode}"
    $command       = "semanage fcontext -a -f ${filemode} -t ${context} \"${pathname}\""
    $unless        = "semanage fcontext -l | grep -E \"^${pathname}.*:${context}:\""
  } else {
    $resource_name = "add_${context}_${pathname}"
    $command       = "semanage fcontext -a -t ${context} \"${pathname}\""
    $unless        = "semanage fcontext -l | grep -E \"^${pathname}.*:${context}:\""
  }

  exec { $resource_name:
    command => $command,
    unless  => $unless,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
