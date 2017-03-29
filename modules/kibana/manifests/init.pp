# Class: kibana
#
# The top-level kibana class that declares child classes for managing kibana.
#
# @example Basic installation
#   class { 'kibana' : }
#
# @example Module removal
#   class { 'kibana' : ensure => absent }
#
# @example Installing a specific version
#   class { 'kibana' : ensure => '5.2.1' }
#
# @example Keep latest version of Kibana installed
#   class { 'kibana' : ensure => 'latest' }
#
# @example Setting a configuration file value
#   class { 'kibana' : config => { 'server.port' => 5602 } }
#
# @param ensure State of Kibana on the system (simple present/absent/latest
#   or version number).
# @param config Hash of key-value pairs for Kibana's configuration file
# @param manage_repo Whether to manage the package manager repository
# @param repo_key_id Trusted GPG Key ID for package repository
# @param repo_key_source Source for repo_key_id
# @param repo_priority Optional repository priority
# @param repo_proxy Proxy to use for repository access (yum only)
# @param repo_version Repository major version to use
#
class kibana (
  Variant[Enum['present', 'absent', 'latest'], Pattern[/^\d([.]\d+)*(-[\d\w]+)?$/]] $ensure          = 'present',
  Hash[String[1], Variant[String[1], Integer, Boolean, Array]]           $config          = {},
  Boolean                                                                $manage_repo     = true,
  String                                                                 $repo_key_id     = '46095ACC8548582C1A2699A9D27D666CD88E42B4',
  String                                                                 $repo_key_source = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
  Optional[Integer]                                                      $repo_priority   = undef,
  Optional[String]                                                       $repo_proxy      = undef,
  Variant[Enum['5.x'], Pattern[/^4\.(1|[4-6])$/]]                        $repo_version    = '5.x',
) {
  class { '::kibana::install': }
  class { '::kibana::config': }
  class { '::kibana::service': }

  # Catch absent values, otherwise default to present/installed ordering
  case $ensure {
    'absent': {
      Class['::kibana::service']
        -> Class['::kibana::config']
        -> Class['::kibana::install']
    }
    default: {
      Class['::kibana::install']
        -> Class['::kibana::config']
        ~> Class['::kibana::service']
    }
  }
}
