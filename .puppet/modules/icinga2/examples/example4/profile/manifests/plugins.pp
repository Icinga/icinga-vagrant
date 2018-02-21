class profile::icinga2::plugins {

  case $::kernel {
    'linux': {
      package { 'nagios-plugins-all': }
    }
  }

}
