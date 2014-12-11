# Class: icinga-reports
#
#   Downloads & installs Icinga Reports into Jasperserver/Tomcat
#   
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.org/)
#
# Parameters:
#
# Actions:
#
# Requires: mariadb, tomcat6, jasperserver, php
#
# Sample Usage:
#
#   include jasperserver
#

class icinga-reports {
  include mariadb
  include tomcat6
  include jasperserver
  include php

  package {"unzip": ensure => "installed"}

  $icingaReportsVersion = '1.10.0'
  $icingaReportsHome = '/home/vagrant'
  $icingaAvailabilityFunctionName = 'icinga_availability'
  $IdoDbName = 'icinga'
  $IdoDbUsername = 'icinga'
  $IdoDbPassword = 'icinga'
  $jasperHome = $jasperserver::jasperHome
  $tomcatHome = $jasperserver::tomcatHome
  $tomcatName = $tomcat6::params::tomcat_name

  # required for icinga-web connector
  php::extension { ['php-soap']:
  }

  Exec['get-icinga-reports'] -> Exec['unzip-icinga-reports'] -> Exec['install-tomcat-mysql-connector']
    -> Exec['install-tomcat-mysql-connector-restart-tomcat'] -> Exec['js-import-icinga']
    -> File["${tomcatHome}/webapps/jasperserver/WEB-INF/lib"] -> Exec['install-jar-files']
    -> Exec['install-ido-icinga-availability-sql-function']

  exec { 'get-icinga-reports':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "/usr/bin/wget -O /tmp/icinga-reports-${icingaReportsVersion}.zip https://github.com/Icinga/icinga-reports/archive/v${icingaReportsVersion}.zip",
    timeout => 0,
    provider => 'shell',
    user => root,
    onlyif => "test ! -f /tmp/icinga-reports-${icingaReportsVersion}.zip"
  }

  exec { 'unzip-icinga-reports':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "unzip -o -q /tmp/icinga-reports-${icingaReportsVersion}.zip -d ${icingaReportsHome}",
    require => [ Package['unzip'], Exec['get-icinga-reports'] ]
  }

  # use connector provided via package repos, already installed via jasperserver
  exec { 'install-tomcat-mysql-connector':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "cp /usr/share/java/mysql-connector-java.jar ${tomcatHome}/lib/",
    require => [ Package['mysql-connector-java'], Package['tomcat6'] ],
  }

  exec { 'install-tomcat-mysql-connector-restart-tomcat': 
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "/etc/init.d/${tomcatName} restart",
    require => Exec['install-tomcat-mysql-connector']  
  }

  exec { 'js-import-icinga':
    command => "${jasperHome}/buildomatic/js-import.sh --input-zip ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/reports/icinga/package/js-icinga-reports.zip",
    require => [ Exec['install-tomcat-mysql-connector'], Package['tomcat6'], Anchor['jasperserver::end'] ],
    cwd => "${icingaReportsHome}/icinga-reports-${icingaReportsVersion}",
    notify => Service['tomcat6']
  }

  file { "${tomcatHome}/webapps/jasperserver/WEB-INF/lib":
    ensure => 'directory',
    require => [ Anchor['jasperserver::end'], Exec['js-import-icinga'] ]
  }

  exec { 'install-jar-files':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "cp ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/jsp-server/classes/icinga/icinga-reporting.jar ${tomcatHome}/webapps/jasperserver/WEB-INF/lib/",
    require => File["${tomcatHome}/webapps/jasperserver/WEB-INF/lib"],
    cwd => "${icingaReportsHome}/icinga-reports-${icingaReportsVersion}",
    notify => Service['tomcat6']
  }

  exec { 'install-ido-icinga-availability-sql-function':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "mysql -u${IdoDbUsername} -p${IdoDbPassword} ${IdoDbName} -e 'select name from mysql.proc where name='${icingaAvailabilityFunctionName}';'",
    command => "mysql -u${IdoDbUsername} -p${IdoDbPassword} ${IdoDbName} < ${icingaReportsHome}/icinga-reports-${icingaReportsVersion}/db/icinga/mysql/availability.sql",
    require => [ Service['mariadb'], Exec['install-jar-files'] ]
  }
}
