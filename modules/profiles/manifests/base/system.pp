class profiles::base::system {
  # fix puppet warning. # TODO: Remove with Puppet 5 support
  # https://ask.puppetlabs.com/question/6640/warning-the-package-types-allow_virtual-parameter-will-be-changing-its-default-value-from-false-to-true-in-a-future-release/
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }

  # disable SELinux everywhere, even it may be already in the used Vagrant box
  class { 'selinux':
    mode => 'disabled'
  }
  ->
  # EPEL repository is needed everywhere
  class { 'epel': }
  ->
  # Icinga repository is required
  class { 'icinga_rpm': } # TODO: Refactor the module
  ->
  # Base packages
  package { [ 'mailx', 'tree', 'gdb', 'rlwrap', 'git', 'bash-completion', 'screen', 'htop', 'unzip' ]:
    ensure => 'installed',
    require => Class['epel']
  }
  ->
  # vim is needed
  class { 'vim':
    opt_bg_shading => 'light',
    require => Class['epel']
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
  exec { 'update-path':
    provider    => shell,
    command     => '. /etc/profile',
    subscribe   => File['/etc/profile.d/env.sh'],
    refreshonly => true
  }
}
