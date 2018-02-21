class profiles::dashing::icinga2 {
  package { [ 'rubygems', 'rubygem-bundler',
              'ruby-devel', 'openssl', 'gcc-c++',
              'make', 'nodejs', 'v8'
             ]:
    ensure => 'installed',
  }->
  vcsrepo { '/usr/share/dashing-icinga2':
    ensure   => 'present',
    path     => '/usr/share/dashing-icinga2',
    provider => 'git',
    revision => 'master',
    source   => 'https://github.com/Icinga/dashing-icinga2.git',
    force    => true,
    require  => Package['git']
  }->
  exec { 'dashing-bundle-install':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "cd /usr/share/dashing-icinga2 && bundle install --jobs 4 --system", # this already installs the dashing binary
    timeout => 1800
  }->
  file { '/usr/lib/systemd/system/dashing-icinga2.service':
    owner  => root,
    group  => root,
    mode   => '0644',
    source	=> '/usr/share/dashing-icinga2/tools/systemd/dashing-icinga2.service',
  }
  ->
  exec { 'dashing-reload-systemd':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    refreshonly => true,
  }
  ->
  service { 'dashing-icinga2':
    provider => 'systemd',
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
}
