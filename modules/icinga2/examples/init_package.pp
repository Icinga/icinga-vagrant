package { 'icinga2':
  ensure => latest,
}
~>
class { '::icinga2':
  manage_package => false,
}
