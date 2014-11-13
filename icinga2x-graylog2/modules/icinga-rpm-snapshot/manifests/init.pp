# Class: icinga-rpm-snapshot
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
#   include icinga-rpm-snapshot
#
class icinga-rpm-snapshot {
  yumrepo { 'icinga-rpm-snapshot':
    baseurl => "http://packages.icinga.org/epel/\$releasever/snapshot/",
    enabled => '1',
    gpgcheck => '1',
    gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA',
    descr => "Icinga Snapshot Packages for Enterprise Linux - ${::architecture}"
  }

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA":
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => "puppet:////vagrant/files/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA" #hardcoded paths are ugly TODO
  }

  icinga-rpm-snapshot::key { "RPM-GPG-KEY-ICINGA":
    path => "/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA",
    before => Yumrepo['icinga-rpm-snapshot']
  }
}

