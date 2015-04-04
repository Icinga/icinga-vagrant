class tomcat6::params {
  case $::osfamily {
    'RedHat': {
      $tomcat_name = 'tomcat6'
      $tomcat_user = 'tomcat'
      $tomcat_settings = '/etc/sysconfig/tomcat6'
    }
    default : {
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }
}
