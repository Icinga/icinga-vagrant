# selinux::fcontext
#
# This define can be used to manage custom SELinux fcontexts. For fcontext 
# equivalences, see selinux::fcontext::equivalence
#
# @example Add a file-context for mysql log files at non standard location
#   selinux::fcontext{'set-mysql-log-context':
#     seltype => "mysqld_log_t",
#     pathspec => "/u01/log/mysql(/.*)?",
#   }
#
# @example Add a file-context only for directory types 
#   selinux::fcontext{'/u/users/[^/]*':
#     filetype => 'd',
#     seltype  => 'user_home_dir_t' ,
#   }
#
# @param ensure   The desired state of the resource. Default: 'present'
# @param seltype  String A particular SELinux type, like "mysqld_log_t"
# @param seluser  String A particular SELinux user, like "sysadm_u"
# @param pathspec String An semanage fcontext-formatted path specification, 
#                        like "/var/log/mysql(/.*)?". Defaults to title
# @param filetype File type the context applies to (i.e. regular file, directory, block device, all files, etc.)
#   - Types:
#       - a = all files (default value if not restricting filetype)
#       - f = regular file
#       - d = directory
#       - c = character device
#       - b = block device
#       - s = socket
#       - l = symbolic link
#       - p = named pipe
define selinux::fcontext(
  String $pathspec                  = $title,
  Enum['absent', 'present'] $ensure = 'present',
  Optional[String] $seltype         = undef,
  Optional[String] $seluser         = undef,
  Optional[String] $filetype        = 'a',
) {

  include ::selinux
  if $ensure == 'present' {
  Anchor['selinux::module post']
  -> Selinux::Fcontext[$title]
  -> Anchor['selinux::end']
  } else {
    Anchor['selinux::start']
    -> Selinux::Fcontext[$title]
    -> Anchor['selinux::module pre']
  }

  if $filetype !~ /^(?:a|f|d|c|b|s|l|p)$/ {
    fail('"filetype" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
  }

  # make sure the title is correct or the provider will misbehave
  selinux_fcontext {"${pathspec}_${filetype}":
    ensure    => $ensure,
    pathspec  => $pathspec,
    seltype   => $seltype,
    file_type => $filetype,
    seluser   => $seluser,
  }
}
