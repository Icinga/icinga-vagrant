class graylog::repository::apt(
  $url,
  $release,
  $version,
  $proxy,
) {
  $apt_transport_package = 'apt-transport-https'
  $gpg_file = '/etc/apt/trusted.gpg.d/graylog-keyring.gpg'
  $package_sources = [
    'downloads.graylog.org',
    'graylog-downloads.herokuapp.com',
    'graylog2-package-repository.s3.amazonaws.com',
  ]

  anchor { 'graylog::repository::apt::begin': }

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

  if $proxy {
    file {'/etc/apt/apt.conf.d/01_graylog_proxy':
      ensure => present,
    }
    # Each file_line resource will append http or https proxy info for its specified source into the 01_graylog_proxy file.
    # If a line already exists for that source, and doesn't match the provided proxy param, that line will be replaced.
    # If a line does not exist for that source, the provided info will be appended.
    $package_sources.each |String $source| {
      file_line { "Acquire::http::proxy::${source}":
        path    => '/etc/apt/apt.conf.d/01_graylog_proxy',
        match   => "Acquire::http::proxy::${source}",
        line    => "Acquire::http::proxy::${source} \"${proxy}\";",
        require => File['/etc/apt/apt.conf.d/01_graylog_proxy'],
        before  => Apt::Source['graylog']
      }
      file_line { "Acquire::https::proxy::${source}":
        path    => '/etc/apt/apt.conf.d/01_graylog_proxy',
        match   => "Acquire::https::proxy::${source}",
        line    => "Acquire::https::proxy::${source} \"${proxy}\";",
        require => File['/etc/apt/apt.conf.d/01_graylog_proxy'],
        before  => Apt::Source['graylog']
      }
    }
  }
  else {
    file {'/etc/apt/apt.conf.d/01_graylog_proxy':
        ensure => present,
    }
    # If proxy parameter has not been provided, remove any existing graylog package sources from the 01_graylog_proxy file (if
    # it exists)
    file_line { 'Remove graylog config from apt proxy file':
      ensure            => absent,
      path              => '/etc/apt/apt.conf.d/01_graylog_proxy',
      match             => 'graylog',
      match_for_absence => true,
      multiple          => true,
      before            => Apt::Source['graylog']
    }
  }

  anchor { 'graylog::repository::apt::end': }

  Anchor['graylog::repository::apt::begin']
  -> Exec['apt_update']
  -> Anchor['graylog::repository::apt::end']
  -> Anchor['graylog::repository::end']
}
