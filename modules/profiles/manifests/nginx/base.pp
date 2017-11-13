class profiles::nginx::base {

  class { 'nginx':
    confd_purge => true,
  }

}
