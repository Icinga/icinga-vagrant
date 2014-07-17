####################################
# Basic stuff
####################################

include epel
include snmp

package { [ 'vim-enhanced', 'mailx' ]:
  ensure => 'installed'
}

file { '/etc/motd':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/motd',
  owner => root,
  group => root
}

file { '/etc/profile.d/env.sh':
  source => 'puppet:////vagrant/.vagrant-puppet/files/etc/profile.d/env.sh'
}

####################################
# Start page at http://localhost/
####################################

file { '/var/www/html/index.html':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/index.html',
  owner     => 'apache',
  group     => 'apache',
  require   => Package['apache']
}

file { '/var/www/html/icinga_wall.png':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/icinga_wall.png',
  owner     => 'apache',
  group     => 'apache',
  require   => Package['apache']
}

####################################
# Plugins
####################################

include nagios-plugins

file { '/usr/lib/nagios/plugins/check_snmp_int.pl':
   source    => 'puppet:////vagrant/.vagrant-puppet/files/usr/lib/nagios/plugins/check_snmp_int.pl',
   owner     => 'root',
   group     => 'root',
   mode      => 755,
   require   => Class['nagios-plugins']
}

####################################
# Icinga 2
####################################

include apache

include icinga-rpm-snapshot
include icinga2
include icinga2-ido-mysql
include mysql

include icinga-classicui
include icinga-web

user { 'vagrant':
  groups  => 'icingacmd',
  require => Package['icinga2']
}

# Icinga 2 Cluster

exec { 'iptables-allow-icinga2-cluster':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  #unless => 'grep -Fxqe "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5665 -j ACCEPT" /etc/sysconfig/iptables',
  command => 'lokkit -p 5665:tcp',
  #notify => Service['icinga2']
}

file { '/etc/icinga2':
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/icinga2.conf':
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/icinga2.conf",
  require   => File['/etc/icinga2']
}

file { '/etc/icinga2/pki':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { '/etc/icinga2/pki/ca.crt':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/ca.crt',
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.crt":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/$hostname.crt",
  require   => File['/etc/icinga2/pki']
}

file { "/etc/icinga2/pki/$hostname.key":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/pki/$hostname.key",
  require   => File['/etc/icinga2/pki']
}

file { '/etc/icinga2/cluster':
  owner  => icinga,
  group  => icinga,
  ensure    => 'directory',
  require => Package['icinga2']
}

file { "/etc/icinga2/cluster/$hostname.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/cluster/$hostname.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}

file { "/etc/icinga2/cluster/cluster.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/cluster/cluster.conf",
  require   => [ File['/etc/icinga2/cluster'], Exec['icinga2-enable-feature-api'] ],
  notify    => Service['icinga2']
}


exec { 'icinga2-enable-feature-api':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'icinga2-enable-feature api',
  require => File['/etc/icinga2/features-available/api.conf'],
  notify => Service['icinga2']
}

# override constants conf and set NodeName elsewhere
file { "/etc/icinga2/constants.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/constants.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# required for icinga2-enable-feature-api
file { "/etc/icinga2/features-available/api.conf":
  owner  => icinga,
  group  => icinga,
  source    => "puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/features-available/api.conf",
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

# cluster zones
file { '/etc/icinga2/zones.d':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d',
  require   => Package['icinga2'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/zones.d/master':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/master',
  require   => File['/etc/icinga2/zones.d'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/zones.d/checker':
  owner  => icinga,
  group  => icinga,
  ensure => present,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker',
  require   => File['/etc/icinga2/zones.d'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/zones.d/master/health.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/master/health.conf',
  require   => File['/etc/icinga2/zones.d/master'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/zones.d/checker/health.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/health.conf',
  require   => File['/etc/icinga2/zones.d/checker'],
  notify    => Service['icinga2']
}



# demo config
file { '/etc/icinga2/zones.d/checker/demo.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/demo.conf',
  require   => File['/etc/icinga2/zones.d/checker'],
  notify    => Service['icinga2']
}

file { '/etc/icinga2/zones.d/checker/templates.conf':
  owner  => icinga,
  group  => icinga,
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icinga2/zones.d/checker/templates.conf',
  require   => File['/etc/icinga2/zones.d/checker'],
  notify    => Service['icinga2']
}



####################################
# Icinga Web 2
####################################

include apache
include mysql
include openldap

# already dclared for icinga-web
#php::extension { ['php-mysql', 'php-ldap']:
#  require => [ Class['mysql'], Class['openldap'] ]
#}
php::extension { 'php-ldap':
  require =>  Class['openldap']
}

php::extension { 'php-gd': }

exec { 'install php-ZendFramework':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'yum -d 0 -e 0 -y --enablerepo=epel install php-ZendFramework',
  unless  => 'rpm -qa | grep php-ZendFramework',
  require => Class['epel']
}

exec { 'install php-ZendFramework-Db-Adapter-Pdo-Mysql':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  command => 'yum -d 0 -e 0 -y --enablerepo=epel install php-ZendFramework-Db-Adapter-Pdo-Mysql',
  unless  => 'rpm -qa | grep php-ZendFramework-Db-Adapter-Pdo-Mysql',
  require => Exec['install php-ZendFramework']
}


exec { 'create-mysql-icingaweb-db':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  unless  => 'mysql -uicingaweb -picingaweb icingaweb',
  command => 'mysql -uroot -e "CREATE DATABASE icingaweb; \
              GRANT ALL ON icingaweb.* TO icingaweb@localhost \
              IDENTIFIED BY \'icingaweb\';"',
  require => Service['mysqld']
}

exec { 'populate-icingaweb-mysql-db-accounts':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM account;" &> /dev/null',
  command => 'mysql -uicingaweb -picingaweb icingaweb < /vagrant/icingaweb2/etc/schema/accounts.mysql.sql',
  require => [ Exec['create-mysql-icingaweb-db'] ]
}

exec { 'populate-icingaweb-mysql-db-preferences':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  unless  => 'mysql -uicingaweb -picingaweb icingaweb -e "SELECT * FROM preference;" &> /dev/null',
  command => 'mysql -uicingaweb -picingaweb icingaweb < /vagrant/icingaweb2/etc/schema/preferences.mysql.sql',
  require => [ Exec['create-mysql-icingaweb-db'] ]
}


file { 'openldap/db.ldif':
  path    => '/usr/share/openldap-servers/db.ldif',
  source  => 'puppet:///modules/openldap/db.ldif',
  require => Class['openldap']
}

file { 'openldap/dit.ldif':
  path    => '/usr/share/openldap-servers/dit.ldif',
  source  => 'puppet:///modules/openldap/dit.ldif',
  require => Class['openldap']
}

file { 'openldap/users.ldif':
  path    => '/usr/share/openldap-servers/users.ldif',
  source  => 'puppet:///modules/openldap/users.ldif',
  require => Class['openldap']
}

exec { 'populate-openldap':
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  # TODO: Split the command and use unless instead of trying to populate openldap everytime
  command => 'sudo ldapadd -c -Y EXTERNAL -H ldapi:/// -f /usr/share/openldap-servers/db.ldif || true && \
              sudo ldapadd -c -D cn=admin,dc=icinga,dc=org -x -w admin -f /usr/share/openldap-servers/dit.ldif || true && \
              sudo ldapadd -c -D cn=admin,dc=icinga,dc=org -x -w admin -f /usr/share/openldap-servers/users.ldif || true',
  require => [ Service['slapd'], File['openldap/db.ldif'],
               File['openldap/dit.ldif'], File['openldap/users.ldif'] ]
}


#
# Development environment (Feature #5554)
#
file { '/var/www/html/icingaweb':
  ensure    => 'directory',
  owner     => 'apache',
  group     => 'apache',
  require   => Package['apache']
}

file { '/var/www/html/icingaweb/css':
  ensure    => 'link',
  target    => '/vagrant/icingaweb2/public/css',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/var/www/html/icingaweb/svg':
  ensure    => 'link',
  target    => '/vagrant/icingaweb2/public/svg',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/var/www/html/icingaweb/img':
  ensure    => 'link',
  target    => '/vagrant/icingaweb2/public/img',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/var/www/html/icingaweb/js':
  ensure    => 'link',
  target    => '/vagrant/icingaweb2/public/js',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/var/www/html/icingaweb/index.php':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/icingaweb/index.php',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/var/www/html/icingaweb/js.php':
  ensure    => absent,
}

file { '/var/www/html/icingaweb/css.php':
  ensure    => absent,
}

file { '/var/www/html/icingaweb/.htaccess':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/var/www/html/icingaweb/.htaccess',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/var/www/html/icingaweb'], Package['apache'] ]
}

file { '/etc/httpd/conf.d/icingaweb.conf':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/httpd/conf.d/icingaweb.conf',
  require   => Package['apache'],
  notify    => Service['apache']
}

file { '/etc/icingaweb':
  ensure    => 'directory',
  require   => Package['apache'],
  owner     => 'apache',
  group     => 'apache'
}

file { '/etc/icingaweb/authentication.ini':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb/authentication.ini',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/config.ini':
  ensure    => file,
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/menu.ini':
  source    => 'puppet:////vagrant/icingaweb2/config/menu.ini',
  owner     => 'apache',
  group     => 'apache',
  replace   => true,
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/resources.ini':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb/resources.ini',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/enabledModules':
  ensure    => 'directory',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/modules':
  ensure    => 'directory',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/modules/monitoring':
  ensure    => 'directory',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb/modules'], Package['apache'] ]
}

file { '/etc/icingaweb/modules/monitoring/backends.ini':
   source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb/modules/monitoring/backends.ini',
   owner     => 'apache',
   group     => 'apache',
  require   => [ File['/etc/icingaweb/modules/monitoring'], Package['apache'] ]
}

file { '/etc/icingaweb/modules/monitoring/instances.ini':
  source    => 'puppet:////vagrant/.vagrant-puppet/files/etc/icingaweb/modules/monitoring/instances.ini',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb/modules/monitoring'], Package['apache'] ]
}

file { '/etc/icingaweb/modules/monitoring/menu.ini':
  source    => 'puppet:////vagrant/icingaweb2/config/modules/monitoring/menu.ini',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb/modules/monitoring'], Package['apache'] ]
}

file { '/etc/icingaweb/dashboard':
  ensure    => 'directory',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb'], Package['apache'] ]
}

file { '/etc/icingaweb/dashboard/dashboard.ini':
   source    => 'puppet:////vagrant/icingaweb2/config/dashboard/dashboard.ini',
   owner     => 'apache',
   group     => 'apache',
  require   => [ File['/etc/icingaweb/dashboard'], Package['apache'] ]
}

# enable monitoring module by default

file { '/etc/icingaweb/enabledModules/monitoring':
  ensure    => 'link',
  target    => '/vagrant/icingaweb2/modules/monitoring',
  owner     => 'apache',
  group     => 'apache',
  require   => [ File['/etc/icingaweb/enabledModules'], Package['apache'] ]
}

# install icingacli

file { '/usr/local/bin/icingacli':
   source    => 'puppet:////vagrant/.vagrant-puppet/files/usr/local/bin/icingacli',
   owner     => 'apache',
   group     => 'apache',
   mode      => 755
}

