# == Class: logstash::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
# https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::package(
  $package_url = $logstash::package_url,
  $version = $logstash::version,
  $package_name = $logstash::package_name,
)
{
  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10,
  }

  #### Package management

  # set params: in operation
  if $logstash::ensure == 'present' {

    # Check if we want to install a specific version or not
    if $version == false {
      $package_ensure = $logstash::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }
    } else {
      # install specific version
      $package_ensure = $version
    }

    # action
    if ($package_url != undef) {
      $filenameArray = split($package_url, '/')
      $basefilename = $filenameArray[-1]

      $sourceArray = split($package_url, ':')
      $protocol_type = $sourceArray[0]

      $extArray = split($basefilename, '\.')
      $ext = $extArray[-1]

      $pkg_source = "/tmp/${basefilename}"

      case $protocol_type {
        'puppet': {
          file { $pkg_source:
            ensure  => file,
            source  => $package_url,
            backup  => false,
            before  => $before,
          }
        }
        'ftp', 'https', 'http': {
          exec { "download_package_logstash_${name}":
            command => "${logstash::params::download_tool} ${pkg_source} ${package_url} 2> /dev/null",
            path    => ['/usr/bin', '/bin'],
            creates => $pkg_source,
            timeout => $logstash::download_timeout,
            before  => $before,
          }
        }
        'file': {
          $source_path = $sourceArray[1]
          file { $pkg_source:
            ensure  => file,
            source  => $source_path,
            backup  => false,
            before  => $before,
          }
        }
        default: {
          fail("Protocol must be puppet, file, http, https, or ftp. You have given \"${protocol_type}\"")
        }
      }

      case $ext {
        'deb':   { $pkg_provider = 'dpkg'  }
        'rpm':   { $pkg_provider = 'rpm'   }
        default: { fail("Unknown file extention \"${ext}\".") }
      }
    } else {
      # Use the OS packaging system to locate the package.
      $pkg_source      = undef
      $pkg_provider    = undef
      if $::osfamily == 'Debian' {
        $require = Class['apt::update']
      }
    }
  } else { # Package removal
    $pkg_source     = undef
    $package_ensure = 'purged'
    if ($::osfamily == 'Suse') {
      $pkg_provider = 'rpm'
    } else {
      $pkg_provider = undef
    }
  }

  package { 'logstash':
    ensure   => $package_ensure,
    name     => $package_name,
    source   => $pkg_source,
    provider => $pkg_provider,
    require  => $require,
  }
}
