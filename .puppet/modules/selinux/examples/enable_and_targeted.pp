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

class { '::selinux':
  mode => 'enforcing',
  type => 'mls',
}
