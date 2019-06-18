class profiles::base::dev (
){
  $icinga_dev_tools = [ 'rpmdevtools', 'ccache',
                        'cmake', 'make', 'gcc-c++', 'flex', 'bison',
                        'openssl-devel', 'boost169-devel', 'systemd-devel',
                        'mysql-devel', 'postgresql-devel', 'libedit-devel',
                        'libstdc++-devel' ]
  package { $icinga_dev_tools:
    ensure => 'installed',
  }
  ->
  group { [ 'icinga', 'icingacmd']:
    ensure => 'present'
  }
  ->
  user { 'icinga':
    groups => [ 'icinga', 'icingacmd' ]
  }
  ->
  vcsrepo { '/root/icinga2':
    ensure => 'present',
    provider => git,
    source => 'https://github.com/icinga/icinga2.git'
  }
  ->
  vcsrepo { '/root/icingaweb2':
    ensure => 'present',
    provider => git,
    source => 'https://github.com/icinga/icingaweb2.git'
  }
  ->
  file { [ '/root/icinga2/debug', '/root/icinga2/release']:
    ensure => 'directory'
  }
  ->
  file { '/etc/profile.d/env_dev.sh':
    content => template("profiles/base/env_dev.sh.erb")
  }
  ->
  exec { 'update-icinga-build-env':
    provider    => shell,
    command     => '. /etc/profile',
    subscribe   => File['/etc/profile.d/env_dev.sh'],
    refreshonly => true
  }
  ->
  file { '/usr/local/bin/gcc':
    ensure => 'link',
    source => '/bin/ccache'
  }
  ->
  file { '/usr/local/bin/g++':
    ensure => 'link',
    source => '/bin/ccache'
  }
}
