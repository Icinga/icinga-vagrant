# This profile must be run before all others
class profiles::base::system {
  # EPEL repository is needed everywhere
  class { 'epel': }
  ->
  # Icinga repository is required
  class { 'icinga_rpm': } # TODO: Refactor the module
  ->
  # Base packages
  package { [ 'mailx', 'tree', 'gdb', 'rlwrap', 'git', 'bash-completion', 'screen', 'htop', 'unzip' ]:
    ensure => 'installed',
  }
  ->
  # vim is needed
  class { 'vim':
    opt_bg_shading => 'light',
  }
  ->
  # Greet with fancy Icinga logo
  file { '/etc/motd':
    owner => root,
    group => root,
    content => template("profiles/base/motd.erb")
  }
  ->
  # ensure PATH is set correctly
  file { '/etc/profile.d/env.sh':
    content => template("profiles/base/env.sh.erb")
  }
  ->
  file { '/etc/gemrc':
    owner => root,
    group => root,
    content => template("profiles/base/gemrc.erb")
  }
  ->
  exec { 'update-path':
    provider    => shell,
    command     => '. /etc/profile',
    subscribe   => File['/etc/profile.d/env.sh'],
    refreshonly => true
  }
}
