package { ['icinga2', 'icinga2-ido-mysql']:
  ensure => latest,
}
~>
class { 'icinga2':
  manage_package => false,
}

include icinga2::feature::idomysql
