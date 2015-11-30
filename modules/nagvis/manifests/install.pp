class nagvis::install {
  $prefix = $nagvis::params::prefix
  $nagvis_version = $::nagvis::params::nagvis_version
  $http_user = $::nagvis::params::http_user
  $http_group = $::nagvis::params::http_group
  $http_conf_dir = $::nagvis::params::http_conf_dir

  # works for rhel7 only
  wget::fetch { 'nagvis':
    source      => "http://www.nagvis.org/share/nagvis-${nagvis_version}.tar.gz",
    destination => "/tmp/nagvis-${nagvis_version}.tar.gz"
  }

  exec { 'extract-nagvis':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "/bin/tar -xzf /tmp/nagvis-${nagvis_version}.tar.gz",
    cwd => "/tmp",
    require => Wget::Fetch['nagvis']
  }

  package { 'graphviz':
    ensure => present
  }

  exec { 'setup-nagvis':
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "cd /tmp/nagvis-${nagvis_version} && ./install.sh -q -p ${prefix} -s Icinga -u ${http_user} -g ${http_group} -w ${http_conf_dir} -i ido2db",
    unless => "test -f ${prefix}",
    cwd => "/tmp/nagvis-${nagvis_version}",
    require  => [ Exec['extract-nagvis'], Class['apache'], Package['graphviz'] ],
    notify => Class['apache::service']
  }
}
