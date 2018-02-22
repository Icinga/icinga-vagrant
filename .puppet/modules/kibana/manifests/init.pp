# @summary The top-level kibana class that declares child classes for managing kibana.
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
# @param package_source Local path to package file for file (not repo) based installation
# @param manage_repo Whether to manage the package manager repository
# @param repo_key_id Trusted GPG Key ID for package repository
# @param repo_key_source Source for repo_key_id
# @param repo_priority Optional repository priority
# @param repo_proxy Proxy to use for repository access (yum only)
# @param repo_version Repository major version to use
# @param status Service status
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class kibana (
  Variant[Enum['present', 'absent', 'latest'], Pattern[/^\d([.]\d+)*(-[\d\w]+)?$/]] $ensure,
  Hash[String[1], Variant[String[1], Integer, Boolean, Array]] $config,
  Boolean $manage_repo,
  Optional[String] $package_source,
  String $repo_key_id,
  String $repo_key_source,
  Optional[Integer] $repo_priority,
  Optional[String] $repo_proxy,
  Variant[Enum['5.x', '6.x'], Pattern[/^4\.(1|[4-6])$/]] $repo_version,
  Kibana::Status $status,
) {

  contain ::kibana::install
  contain ::kibana::config
  contain ::kibana::service

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
