include apache
include icinga
include icinga-classicui
include icinga-idoutils-libdbi-mysql
include icinga-web
include icinga-reports
include nagios-plugins

package { 'vim-enhanced':
  ensure => 'installed'
}

# icinga demo docs at /icinga-demo
file { '/etc/httpd/conf.d/icinga-demo.conf':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/httpd/conf.d/icinga-demo.conf',
  require => [ Package['apache'], File['/usr/share/icinga-demo/htdocs/index.html'], Package['icinga-gui'], Package['icinga-web'] ],
  notify => Service['apache']
}

file { [ '/usr/share/icinga-demo', '/usr/share/icinga-demo/htdocs' ]:
  owner => root,
  group => root,
  mode => 755,
  ensure => 'directory'
}

file { '/usr/share/icinga-demo/htdocs/index.html':
  source => 'puppet:////vagrant/.vagrant-puppet/files/usr/share/icinga-demo/htdocs/index.html',
  owner => root,
  group => root,
  mode => 644
}

file { '/usr/share/icinga-demo/htdocs/icinga_wall.png':
  source => 'puppet:////vagrant/.vagrant-puppet/files/usr/share/icinga-demo/htdocs/icinga_wall.png',
  owner => root,
  group => root,
  mode => 644
}


file { '/etc/motd':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/motd',
  owner => root,
  group => root
}

user { 'vagrant':
  groups  => ['icinga', 'icingacmd'],
  require => [User['icinga'], Group['icingacmd']]
}
