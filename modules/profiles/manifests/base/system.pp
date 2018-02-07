# This profile must be run before all others
class profiles::base::system {
  # EPEL repository is needed everywhere
  class { 'epel': }
  ->
  # Icinga repository is required
  yumrepo { 'icinga-snapshot-builds':
    baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/snapshot/",
    descr    => 'ICINGA (snapshot builds for epel)',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'http://packages.icinga.com/icinga.key',
  }
  ->
  yumrepo { 'icinga-stable-release':
    baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/release/",
    descr    => 'ICINGA (stable release for epel)',
    enabled  => 0,
    gpgcheck => 1,
    gpgkey   => 'http://packages.icinga.com/icinga.key',
  }
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
  ->
  # This can be used to wait for a given URL parameter, e.g. Kibana or Icinga 2 API
  file { '/usr/local/bin/http-conn-validator':
    owner => root,
    group => root,
    mode  => '0755',
    content => template("profiles/base/http-conn-validator.erb")
  }
}
