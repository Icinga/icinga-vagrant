# Class: wget
#
#   This class installs wget.
#
#   Copyright (C) 2014-present Icinga Development Team (http://www.icinga.com/)
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   include wget
#
class wget {
  package { 'wget':
    ensure => installed,
  }
}
