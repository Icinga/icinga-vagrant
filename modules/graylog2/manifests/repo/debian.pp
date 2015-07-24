# == Class: graylog2::repo::debian
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::repo::debian (
  $repo_name,
  $baseurl,
  $release,
  $repos,
  $pin
) {

  if !defined(Package['apt-transport-https']) {
    ensure_packages(['apt-transport-https'])
  }

  if !defined(Apt::Source[$repo_name]) {
    apt::source { $repo_name:
      location          => $baseurl,
      release           => $release,
      repos             => $repos,
      pin               => $pin,
      include_src       => false,
      required_packages => ['apt-transport-https'],
      require           => File['/etc/apt/trusted.gpg.d/graylog2-keyring.gpg']
    }

    file {'/etc/apt/trusted.gpg.d/graylog2-keyring.gpg':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
      source => 'puppet:///modules/graylog2/graylog2-keyring.gpg',
    }
  }
}
