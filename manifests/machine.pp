# == Class: docker::machine
#
# Class to install Docker Machine using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Docker Machine
#   Valid values are absent present
#   Defaults to present
#
# [*version*]
#   The version of Docker Machine to install.
#   Defaults to the value set in $docker::params::machine_version
#
# [*install_path*]
#   The path where to install Docker Machine.
#   Defaults to the value set in $docker::params::machine_install_path
#
# [*proxy*]
#   Proxy to use for downloading Docker Machine.
#
class docker::machine(
  Optional[Pattern[/^present$|^absent$/]] $ensure          = 'present',
  Optional[String] $version                                = $docker::params::machine_version,
  Optional[String] $install_path                           = $docker::params::machine_install_path,
  Optional[String] $proxy                                  = undef
) inherits docker::params {

  if $proxy != undef {
    validate_re($proxy, '^((http[s]?)?:\/\/)?([^:^@]+:[^:^@]+@|)([\da-z\.-]+)\.([\da-z\.]{2,6})(:[\d])?([\/\w \.-]*)*\/?$')
  }

  if $::osfamily == 'windows' {
    $file_extension = '.exe'
    $file_owner = 'Administrator'
  } else {
    $file_extension = ''
    $file_owner = 'root'
  }

  $docker_machine_location = "${install_path}/docker-machine${file_extension}"
  $docker_machine_location_versioned = "${install_path}/docker-machine-${version}${file_extension}"

  if $ensure == 'present' {
    $docker_machine_url = "https://github.com/docker/machine/releases/download/v${version}/docker-machine-${::kernel}-x86_64${file_extension}"

    if $proxy != undef {
      $proxy_opt = "--proxy ${proxy}"
    } else {
      $proxy_opt = ''
    }

    if $::osfamily == 'windows' {
# lint:ignore:140chars
      $docker_download_command = "if (Invoke-WebRequest ${docker_machine_url} ${proxy_opt} -UseBasicParsing -OutFile \"${docker_machine_location_versioned}\") { exit 0 } else { exit 1}"
# lint:endignore

      exec { "Install Docker Machine ${version}":
        command  => template('docker/windows/download_docker_machine.ps1.erb'),
        provider => powershell,
        creates  => $docker_machine_location_versioned,
      }

      file { $docker_machine_location:
        ensure  => 'link',
        target  => $docker_machine_location_versioned,
        require => Exec["Install Docker Machine ${version}"]
      }
    } else {
      ensure_packages(['curl'])
      exec { "Install Docker Machine ${version}":
        path    => '/usr/bin/',
        cwd     => '/tmp',
        command => "curl -s -S -L ${proxy_opt} ${docker_machine_url} -o ${docker_machine_location_versioned}",
        creates => $docker_machine_location_versioned,
        require => Package['curl'],
      }

      file { $docker_machine_location_versioned:
        owner   => $file_owner,
        mode    => '0755',
        require => Exec["Install Docker Machine ${version}"]
      }

      file { $docker_machine_location:
        ensure  => 'link',
        target  => $docker_machine_location_versioned,
        require => File[$docker_machine_location_versioned]
      }
    }
  } else {
    file { [
      $docker_machine_location_versioned,
      $docker_machine_location
      ]:
      ensure => absent,
    }
  }
}
