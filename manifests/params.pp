# == Class: graylog2::params
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::params {

  $repo_name = 'graylog2'

  $repo_release = $::osfamily ? {
    'Debian' => $::lsbdistcodename,
    'RedHat' => '',
    default  => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_pin = 200

  $repo_key_source = $::osfamily ? {
      'Debian' => '',
      'Redhat' => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-graylog2',
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_gpgcheck = $::osfamily ? {
      'Debian' => 0,
      'Redhat' => 1,
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

  $repo_enabled = $::osfamily ? {
      'Debian' => 0,
      'Redhat' => 1,
      default => fail("${::osfamily} is not supported by ${module_name}")
  }

}
