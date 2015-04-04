# Class:
#
# Description
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

selinux::module { 'apache-selinux':
  ensure => 'present',
  source => 'puppet:///modules/apache/selinux/apache.te',
}
