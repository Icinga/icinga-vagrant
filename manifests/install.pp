# == Class: kibana5::install
#
# Installs Kibana5 on either RedHat or Debian based systems. Optionally manages
# the repo for the source of the package.
#
# === Parameters
#
# See documentation in the main Kibana5 class
#
class kibana5::install (
  $manage_repo          = $kibana5::manage_repo,
  $package_repo_version = $kibana5::package_repo_version,
  $package_repo_proxy   = $kibana5::package_repo_proxy,
  $version              = $kibana5::version,
) inherits kibana5 {

  if ($manage_repo) {

    case $::osfamily {

      'RedHat': {
        yumrepo { "kibana-${package_repo_version}":
          baseurl  => "https://artifacts.elastic.co/packages/${package_repo_version}/yum",
          enabled  => '1',
          gpgcheck => '1',
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          descr    => "Kibana repository for ${package_repo_version} packages",
          proxy    => $package_repo_proxy,
          before   => Package['kibana5'],
        }
      }

      'Debian': {
        include ::apt
        apt::source { "kibana-${package_repo_version}":
          location => "http://artifacts.elastic.co/packages/${package_repo_version}/apt",
          release  => 'stable',
          repos    => 'main',
          key      => {
            'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
            'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          },
          include  => {
            'src' => false,
          },
          before   => Package['kibana5'],
        }
      }

      default: {
        fail("${::operatingsystem} not supported")
      }
    }
  }

  package { 'kibana5':
    ensure => $version,
    name   => 'kibana',
  }
}
