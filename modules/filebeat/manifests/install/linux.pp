class filebeat::install::linux {
  package {'filebeat':
    ensure => $filebeat::package_ensure,
  }
}
