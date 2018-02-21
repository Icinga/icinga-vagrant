class graylog::repository::apt(
  $url,
  $release,
  $version,
) {
  $apt_transport_package = 'apt-transport-https'
  $gpg_file = '/etc/apt/trusted.gpg.d/graylog-keyring.gpg'

  if !defined(Package[$apt_transport_package]) {
    ensure_packages([$apt_transport_package])
  }

  file { $gpg_file:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => 'puppet:///modules/graylog/graylog-keyring.gpg',
    notify => Exec['apt_update'],
  }

  apt::source { 'graylog':
    comment  => 'The official Graylog package repository',
    location => $url,
    release  => $release,
    repos    => $version,
    include  => {
      'deb' => true,
      'src' => false,
    },
    require  => [
      File[$gpg_file],
      Package[$apt_transport_package],
    ],
    notify   => Exec['apt_update'],
  }
}
