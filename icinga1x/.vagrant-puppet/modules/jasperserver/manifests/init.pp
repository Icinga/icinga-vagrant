# Class: jasperserver
#
#   Downloads & installs Jasperserver with Tomcat & MySQL
#   
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.org/)
#
# Parameters:
#
# Actions:
#
# Requires: mysql, tomcat6
#
# Sample Usage:
#
#   include jasperserver
#

class jasperserver {
  include mysql
  include tomcat6

  $jasperVersion = "5.5.0a"
  $jasperHome = "/opt/jasperreports-server-cp-${jasperVersion}-bin"
  $jasperBuildomaticDefaultMasterProperties = "${jasperHome}/buildomatic/default_master.properties"

  $jasperDbType = "mysql"
  $jasperDbHost = "localhost"
  $jasperDbUsername = "jasperserver"
  $jasperDbPassword = "jasperserver"
  $jasperDbName = "jasperserver"

  $tomcatHome = "/usr/share/tomcat6"

  $mysqlJavaConnectorVersion = "5.1.17"
  $javaPackageName = "java-1.7.0-openjdk"

  anchor { 'jasperserver::end': } 

  Package["${javaPackageName}"] -> Exec['create-mysql-jasperserver-user'] -> Exec['get-jasperserver-binary']
    -> File["${jasperHome}"] -> Exec['unzip-jasperserver-binary'] -> Package['mysql-connector-java']
    -> Exec['install-mysql-connector-java'] -> File["${jasperBuildomaticDefaultMasterProperties}"]
    -> Exec['import-jasperserver-schema-js-create'] -> Exec['import-jasperserver-schema-quartz']
    -> Exec['install-jasperserver-catalog-minimal'] -> Exec['install-jasperserver-wepapp']

  package { "${javaPackageName}":
    ensure => 'installed',
    before => Exec['get-jasperserver-binary']
  }

  exec { 'create-mysql-jasperserver-user':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    unless => "mysql -u${jasperDbUsername} -p${jasperDbPassword} ${jasperDbName}",
    command => "mysql -uroot -p${mysql::mysqlRootPassword} -e \"CREATE DATABASE ${jasperDbName}; GRANT ALL ON ${jasperDbName}.* TO ${jasperDbUsername}@${jasperDbHost} IDENTIFIED BY \'${jasperDbPassword}\';\"",
    require => Service['mysqld']
  }

  exec { 'get-jasperserver-binary':
    command => "/usr/bin/wget -O /tmp/jasperreports-server-cp-${jasperVersion}-bin.zip http://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20Edition%20${jasperVersion}/jasperreports-server-cp-${jasperVersion}-bin.zip",
    timeout => 0,
    provider => 'shell',
    user => root, 
    require => Exec['create-mysql-jasperserver-user'],
    onlyif => "test ! -f /tmp/jasperreports-server-cp-${jasperVersion}-bin.zip"
  }

  file { "${jasperHome}":
    ensure => 'directory',
    purge => true,
    owner => root,
    group => root
  }

  exec { 'unzip-jasperserver-binary':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "unzip -o -q /tmp/jasperreports-server-cp-${jasperVersion}-bin.zip -d ${jasperHome}/..",
    provider => 'shell',
    require => [ Package['unzip'], Exec['get-jasperserver-binary'], File["${jasperHome}"] ]
  }

  # required on centos http://community.jaspersoft.com/questions/815738/resolvedjasperreports-server-centos-6-build-failed-validationxml
  package { 'mysql-connector-java':
    ensure => installed,
    require => Class['epel'],
    alias => 'mysql-connector-java'
  }

  exec { 'install-mysql-connector-java':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "cp /usr/share/java/mysql-connector-java-${mysqlJavaConnectorVersion}.jar ${jasperHome}/buildomatic/conf_source/db/mysql/jdbc",
    require => [ Package['mysql-connector-java'], Exec['unzip-jasperserver-binary'] ],
  }

  file { "${jasperBuildomaticDefaultMasterProperties}":
    content => template("jasperserver/default_master.properties.erb"),
    require => Exec['install-mysql-connector-java'],
    owner => root,
    group => root
  }

  exec { 'import-jasperserver-schema-js-create':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "mysql -u${jasperDbUsername} -p${jasperDbPassword} ${jasperDbName} -e 'SELECT * FROM JIUser LIMIT 1'",
    command => "mysql -u${jasperDbUsername} -p${jasperDbPassword} ${jasperDbName} < install_resources/sql/mysql/js-create.ddl",
    require => File["${jasperHome}/buildomatic/default_master.properties"],
    cwd => "${jasperHome}/buildomatic",
  }
    
  exec { 'import-jasperserver-schema-quartz':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    unless => "mysql -u${jasperDbUsername} -p${jasperDbPassword} ${jasperDbName} -e 'SELECT * FROM QRTZ_CALENDARS LIMIT 1'",
    command => "mysql -u${jasperDbUsername} -p${jasperDbPassword} ${jasperDbName} < install_resources/sql/mysql/quartz.ddl",
    require => Exec['import-jasperserver-schema-js-create'],
    cwd => "${jasperHome}/buildomatic",
  }
    
  exec { 'install-jasperserver-catalog-minimal':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "${jasperHome}/buildomatic/js-ant import-minimal-ce",
    require => Exec['import-jasperserver-schema-quartz'],
    cwd => "${jasperHome}/buildomatic",
    user => root,
    before => Anchor['jasperserver::end']
  }

  exec { 'install-jasperserver-wepapp':
    path => "/bin:/usr/bin:/sbin:/usr/sbin",
    command => "${jasperHome}/buildomatic/js-ant deploy-webapp-ce",
    require => Exec['install-jasperserver-catalog-minimal'],
    cwd => "${jasperHome}/buildomatic",
    user => root,
    before => Anchor['jasperserver::end'],
    notify => Service['tomcat6']
  }
}
