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
#    - $restorecond: Boolean Value - Run restorecon against the path name upon changes (default true)
#    - $restorecond_path: Path name to use for restorecon, (default $pathname)
#
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
  $destination         = undef,
  $context             = undef,
  $filetype            = false,
  $filemode            = 'a',
  $equals              = false,
  $restorecond         = true,
  $restorecond_path    = undef,
  $restorecond_recurse = false,
) {

  include ::selinux

  validate_absolute_path($pathname)
  validate_bool($filetype, $equals)

  if $equals {
    validate_absolute_path($destination)
  } else {
    validate_string($context)
  }

  $restorecond_path_private = $restorecond_path ? {
    undef   => $pathname,
    default => $restorecond_path
  }

  validate_absolute_path($restorecond_path_private)

  $restorecond_resurse_private = $restorecond_recurse ? {
    true  => ['-R'],
    false => [],
  }

  if $equals and $filetype {
    fail('Resource cannot contain both "equals" and "filetype" options')
  }

  if $equals {
    $resource_name = "add_${destination}_${pathname}"
    $command       = shellquote('semanage', 'fcontext','-a', '-e', $destination, $pathname)
    $unless        = sprintf('semanage fcontext -l | grep -Fx %s', shellquote("${pathname} = ${destination}"))
  } else {
    if $filemode !~ /^(?:a|f|d|c|b|s|l|p)$/ {
      fail('"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
    }
    $resource_name = "add_${context}_${pathname}_type_${filemode}"
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '6' {
      case $filemode {
        'a': {
          $_filemode = 'all files'
          $_quotedfilemode = '\'all files\''
          }
        default: {
          $_filemode = $filemode
          $_quotedfilemode = $_filemode
        }
      }
    } else {
      $_filemode = $filemode
      $_quotedfilemode = $_filemode
    }
    $command       = shellquote('semanage', 'fcontext','-a', '-f', $_filemode, '-t', $context, $pathname)
    $unless        = sprintf('semanage fcontext -E | grep -Fx %s', shellquote("fcontext -a -f ${_quotedfilemode} -t ${context} '${pathname}'"))
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { $resource_name:
    command => $command,
    unless  => $unless,
    require => Class['selinux::package'],
  }

  if $restorecond {
    exec { "restorecond ${resource_name}":
      command     => shellquote('restorecon', $restorecond_resurse_private, $restorecond_path_private),
      onlyif      => shellquote('test', '-e', $restorecond_path_private),
      refreshonly => true,
      subscribe   => Exec[$resource_name],
    }
  }

}
