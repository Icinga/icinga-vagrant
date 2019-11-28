class profiles::graylog::mongodb (
  $version = '4.0.0',
) {
  class { '::mongodb::globals':
    manage_package_repo => true,
    version => $version
  } ->
  class { '::mongodb::server': }
}

