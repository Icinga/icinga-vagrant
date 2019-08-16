class graylog::server(
  $package_version = $graylog::params::package_version,
  $config = undef,
  $user = $graylog::params::server_user,
  $group = $graylog::params::server_group,
  $ensure = running,
  $enable = true,
) inherits graylog::params {
  if $config == undef {
    fail('Missing "config" setting!')
  }
  if ! is_hash($config) {
    fail('$config needs to be a hash data type!')
  }

  # Check mandatory settings
  if ! has_key($config, 'password_secret') {
    fail('Missing "password_secret" config setting!')
  }
  if has_key($config, 'root_password_sha2') {
    if length($config['root_password_sha2']) < 64 {
      fail('The root_password_sha2 parameter does not look like a SHA256 checksum!')
    }
  } else {
    fail('Missing "root_password_sha2" config setting!')
  }

  $data = merge($::graylog::params::default_config, $config)

  anchor { 'graylog::server::start': }
  anchor { 'graylog::server::end': }

  package { 'graylog-server':
    ensure => $package_version
  }

  file { '/etc/graylog/server/server.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => template("${module_name}/server/graylog.conf.erb"),
  }

  service { 'graylog-server':
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  Anchor['graylog::server::start']
  ->Package['graylog-server']
  ->File['/etc/graylog/server/server.conf']
  ~>Service['graylog-server']
  ->Anchor['graylog::server::end']
}
