class profiles::base::java {

  class { 'java':
    version      => 'latest',
    distribution => 'jdk'
  }

}
