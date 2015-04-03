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

class { 'selinux':
  mode => 'disabled',
}

# Also acceptable
# class { 'selinux':
#   mode => 'permissive',
# }

