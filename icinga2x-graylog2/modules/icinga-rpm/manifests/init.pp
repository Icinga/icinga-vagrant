# Class: icinga-rpm
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
#   include icinga-rpm
#
class icinga-rpm {
  yumrepo { 'icinga-rpm':
    baseurl => "http://packages.icinga.org/epel/\$releasever/release/",
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

  icinga-rpm::key { "RPM-GPG-KEY-ICINGA":
    path => "/etc/pki/rpm-gpg/RPM-GPG-KEY-ICINGA",
    before => Yumrepo['icinga-rpm']
  }
}

