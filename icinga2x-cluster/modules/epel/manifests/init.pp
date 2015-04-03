# Class: epel
#
#   Configure EPEL repository.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include epel
#
class epel {
  yumrepo { 'epel':
    mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-\$releasever&arch=${::architecture}",
    enabled => '1',
    gpgcheck => '1',
    gpgkey => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL',
    descr => "Extra Packages for Enterprise Linux - ${::architecture}"
  }

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL":
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => "puppet:////vagrant/files/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL"
  }

  epel::key { "RPM-GPG-KEY-EPEL":
    path => "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL",
    before => Yumrepo['icinga-rpm-snapshot']
  }
}

