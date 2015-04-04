# Class: icinga_rpm
#
#   Configure Icinga repositories.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include icinga_rpm
#
class icinga_rpm (
  $use_snapshot_repo = $::icinga_rpm::params::use_snapshot_repo
) inherits icinga_rpm::params {

  validate_bool($use_snapshot_repo)

  $repo = "http://packages.icinga.org/epel/\$releasever/"

  if $use_snapshot_repo {
    notify { 'icinga rpm packages':
      name => 'Using the snapshot package repository',
      withpath => true,
    }
    $baseurl = "$repo/snapshot/"
  } else {
    $baseurl = "$repo/release/"
  }

  yumrepo { 'icinga_rpm':
    baseurl => $baseurl,
    enabled => '1',
    gpgcheck => '1',
    gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA',
    descr => "Icinga Packages for Enterprise Linux - ${::architecture}"
  }

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA":
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => "puppet:////vagrant/files/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA" #hardcoded paths are ugly TODO
  }

  icinga_rpm::key { "RPM-GPG-KEY-ICINGA":
    path => "/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA",
    before => Yumrepo['icinga_rpm']
  }
}

