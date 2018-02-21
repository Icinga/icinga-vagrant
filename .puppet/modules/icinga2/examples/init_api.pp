class { 'icinga2':
  manage_repo => true,
}

include icinga2::feature::api

#icinga2::object::zone { 'global-templates':
#  global => true,
#}
