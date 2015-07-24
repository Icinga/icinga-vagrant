# == Class: graylog2::repo::redhat
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::repo::redhat (
  $repo_name,
  $baseurl,
  $gpgkey,
  $gpgcheck,
  $enabled,
) {

  if !defined(Yumrepo[$repo_name]) {
    yumrepo { $repo_name:
      baseurl  => $baseurl,
      gpgkey   => $gpgkey,
      gpgcheck => $gpgcheck,
      enabled  => $enabled,
      descr    => 'This is Graylog2',
      require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog2'],
    }

    file {'/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog2':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => 'puppet:///modules/graylog2/RPM-GPG-KEY-graylog2',
    }
  }
}
