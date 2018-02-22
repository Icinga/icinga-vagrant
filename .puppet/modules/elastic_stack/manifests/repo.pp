# elastic_stack::repo
#
# @summary Set up the package repository for Elastic Stack components
#
# @example
#   include elastic_stack::repo
#
# @param version The (major) version of the Elastic Stack for which to configure the repo
# @param priority A numeric priority for the repo, passed to the package management system
# @param proxy The URL of a HTTP proxy to use for package downloads (YUM only)
# @param prerelease Whether to use a repo for prerelease versions, like "6.0.0-rc2"
class elastic_stack::repo(
  Integer $version=6,
  Integer $priority=10,
  String $proxy='absent',
  Boolean $prerelease=false,
)

{
  if $prerelease {
    $url_suffix = '-prerelease'
  }
  else {
    $url_suffix = ''
  }
  $base_url = "https://artifacts.elastic.co/packages/${version}.x${url_suffix}"
  $key_id='46095ACC8548582C1A2699A9D27D666CD88E42B4'
  $key_source='https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  $description='Elastic package repository.'

  case $::osfamily {
    'Debian': {
      include apt
      Class['apt::update'] -> Package <| |>

      apt::source { 'elastic':
        ensure   => 'present',
        comment  => $description,
        location => "${base_url}/apt",
        release  => 'stable',
        repos    => 'main',
        key      => {
          'id'     => $key_id,
          'source' => $key_source,
        },
        include  => {
          'deb' => true,
          'src' => false,
        },
        pin      => $priority,
      }
    }
    'RedHat', 'Linux': {
      yumrepo { 'elastic':
        descr    => $description,
        baseurl  => "${base_url}/yum",
        gpgcheck => 1,
        gpgkey   => $key_source,
        enabled  => 1,
        proxy    => $proxy,
        priority => $priority,
      }
      ~> exec { 'elasticsearch_yumrepo_yum_clean':
        command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="elasticsearch"',
        refreshonly => true,
        returns     => [0, 1],
        path        => [ '/bin', '/usr/bin', '/usr/local/bin' ],
        cwd         => '/',
      }
    }
    'Suse': {
      # Older versions of SLES do not ship with rpmkeys
      if $::operatingsystem == 'SLES' and versioncmp($::operatingsystemmajrelease, '11') <= 0 {
        $_import_cmd = "rpm --import ${::elasticsearch::repo_key_source}"
      }
      else {
        $_import_cmd = "rpmkeys --import ${::elasticsearch::repo_key_source}"
      }

      exec { 'elasticsearch_suse_import_gpg':
        command => $_import_cmd,
        unless  => "test $(rpm -qa gpg-pubkey | grep -i 'D88E42B4' | wc -l) -eq 1",
        notify  => Zypprepo['elasticsearch'],
        path    => [ '/bin', '/usr/bin', '/usr/local/bin' ],
        cwd     => '/',
      }

      zypprepo { 'elastic':
        baseurl     => "${base_url}/yum",
        enabled     => 1,
        autorefresh => 1,
        name        => 'elastic',
        gpgcheck    => 1,
        gpgkey      => $key_source,
        type        => 'yum',
      }
      ~> exec { 'elasticsearch_zypper_refresh_elastic':
        command     => 'zypper refresh elastic',
        refreshonly => true,
        path        => [ '/bin', '/usr/bin', '/usr/local/bin' ],
        cwd         => '/',
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
