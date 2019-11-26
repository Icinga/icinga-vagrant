# This profile must be run before all others
class profiles::base::system (
  $icinga_repo = 'snapshot'
){
  class { 'timezone':
     timezone => 'Europe/Berlin', #keep using the same as PHP
  }
  ->
  class { selinux:
    mode => 'disabled',
  }
  ->
  # EPEL repository is needed everywhere
  class { 'epel': }
  ->
  # Icinga repository is required
  yumrepo { 'icinga-snapshot-builds':
    baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/snapshot/",
    descr    => 'ICINGA (snapshot builds for epel)',
    enabled  => $icinga_repo ? { 'snapshot' => 1, default => 0 },
    gpgcheck => 1,
    gpgkey   => 'http://packages.icinga.com/icinga.key',
  }
  ->
  yumrepo { 'icinga-stable-release':
    baseurl  => "http://packages.icinga.com/epel/${::operatingsystemmajrelease}/release/",
    descr    => 'ICINGA (stable release for epel)',
    enabled  => $icinga_repo ? { 'release' => 1, default => 0 },
    gpgcheck => 1,
    gpgkey   => 'http://packages.icinga.com/icinga.key',
  }
  ->
  # Base packages
  package { [ 'mailx', 'tree', 'gdb', 'lsof', 'git', 'bash-completion', 'screen', 'htop', 'unzip' ]:
    ensure => 'installed',
  }
  ->
  # Python
  package { [ 'python36', 'python36-requests' ]:
    ensure => 'installed',
  }
  ->
  # curl/nss for latest TLS
  package { [ 'curl', 'nss' ]:
    ensure => 'latest',
  }
  ->
  # wget
  class { 'wget':
    package_manage => true,
    package_ensure => present,
    package_name   => 'wget'
  }
  ->
  # Chromium headless for Icinga reporting PDF export
  #package { 'chromium-headless': # currently doesn't work for me
  #  require => Class['epel']
  #}
  #->
  yumrepo { 'google-chrome-stable':
    baseurl 	=> 'http://dl.google.com/linux/chrome/rpm/stable/$basearch',
    enabled	=> 1,
    gpgcheck	=> 1,
    gpgkey 	=> 'https://dl-ssl.google.com/linux/linux_signing_key.pub'
  }
  ->
  package { [ 'google-chrome-stable', 'mesa-libOSMesa', 'mesa-libOSMesa-devel', 'gnu-free-sans-fonts', 'ipa-gothic-fonts', 'ipa-pgothic-fonts' ]:
    ensure => 'installed'
  }
  ->
  # vim is needed
  class { 'vim':
    opt_bg_shading => 'light',
  }
  # snmp
  class { 'snmp':
    agentaddress => [ 'udp:161', 'udp6:161' ],
    ro_community => 'public'
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
