# == Class: graylog2::repo
#
# === Authors
#
# Johannes Graf <graf@synyx.de>
#
# === Copyright
#
# Copyright 2014 synyx GmbH & Co. KG
#
class graylog2::repo (
  $version,
  $repo_name  = $graylog2::params::repo_name,
  $baseurl    = undef,
  $repos      = $graylog2::params::repo_repos,
  $release    = $graylog2::params::repo_release,
  $pin        = $graylog2::params::repo_pin,
  $key_source = $graylog2::params::repo_key_source,
  $gpgcheck   = $graylog2::params::repo_gpgcheck,
  $enabled    = $graylog2::params::repo_enabled,
) inherits graylog2::params {

  anchor { 'graylog2::repo::begin': }
  anchor { 'graylog2::repo::end': }

  if $baseurl {
    $repo_baseurl = $baseurl
  } else {
    $repo_baseurl = $::osfamily ? {
        'Debian' => 'https://packages.graylog2.org/repo/debian/',
        'RedHat' => "https://packages.graylog2.org/repo/el/\$releasever/${version}/\$basearch/",
        default  => fail("${::osfamily} is not supported by ${module_name}")
    }
  }

  case $::osfamily {
    'Debian': {
      class {'graylog2::repo::debian':
        repo_name  => $repo_name,
        baseurl    => $repo_baseurl,
        repos      => $version,
        release    => $release,
        pin        => $pin,
        require    => Anchor['graylog2::repo::begin'],
        before     => Anchor['graylog2::repo::end'],
      }
    }
    'RedHat': {
      class { 'graylog2::repo::redhat':
        repo_name => $repo_name,
        baseurl   => $repo_baseurl,
        gpgkey    => $key_source,
        gpgcheck  => $gpgcheck,
        enabled   => $enabled,
        require   => Anchor['graylog2::repo::begin'],
        before    => Anchor['graylog2::repo::end'],
      }
    }
    default: { fail("${::osfamily} is not supported by ${module_name}") }
  }

}
