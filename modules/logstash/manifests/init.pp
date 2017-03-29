# This class manages installation, configuration and execution of Logstash 5.x.
#
# @param [String] ensure
#   Controls if Logstash should be `present` or `absent`.
#
#   If set to `absent`, the Logstash package will be
#   uninstalled. Related files will be purged as much as possible. The
#   exact behavior is dependant on the service provider, specifically its
#   support for the 'purgable' property.
#
# @param [Boolean] auto_upgrade
#   If set to `true`, Logstash will be upgraded if the package provider is
#   able to find a newer version.  The exact behavior is dependant on the
#   service provider, specifically its support for the 'upgradeable' property.
#
# @param [String] status
#   The desired state of the Logstash service. Possible values:
#
#   - `enabled`: Service running and started at boot time.
#   - `disabled`: Service stopped and not started at boot time.
#   - `running`: Service running but not be started at boot time.
#   - `unmanaged`: Service will not be started at boot time. Puppet
#      will neither stop nor start the service.
#
# @param [String] version
#   The specific version to install, if desired.
#
# @param [Boolean] restart_on_change
#   Restart the service whenever the configuration changes.
#
#   Disabling automatic restarts on config changes may be desired in an
#   environment where you need to ensure restarts occur in a
#   controlled/rolling manner rather than during a Puppet run.
#
# @param [String] package_url
#   Explict Logstash package URL to download.
#
#   Valid URL types are:
#   - `http://`
#   - `https://`
#   - `ftp://`
#   - `puppet://`
#   - `file:/`
#
# @param [String] package_name
#   The name of the Logstash package in the package manager.
#
# @param [Integer] download_timeout
#   Timeout, in seconds, for http, https, and ftp downloads.
#
# @param [String] logstash_user
#   The user that Logstash should run as. This also controls file ownership.
#
# @param [String] logstash_group
#   The group that Logstash should run as. This also controls file group ownership.
#
# @param [Boolean] purge_config
#   Purge the config directory of any unmanaged files,
#
# @param [String] service_provider
#   Service provider (init system) to use. By Default, the module will try to
#   choose the 'standard' provider for the current distribution.
#
# @param [Hash] settings
#   A collection of settings to be defined in `logstash.yml`.
#
#   See: https://www.elastic.co/guide/en/logstash/current/logstash-settings-file.html
#
# @param [Hash] startup_options
#   A collection of settings to be defined in `startup.options`.
#
#   See: https://www.elastic.co/guide/en/logstash/current/config-setting-files.html
#
# @param [Array] jvm_options
#   A collection of settings to be defined in `jvm.options`.
#
# @param [Boolean] manage_repo
#   Enable repository management. Configure the official repositories.
#
# @param [String] repo_version
#   Logstash repositories are defined by major version. Defines the major
#   version to manage.
#
# @param [String] config_dir
#   Path containing the Logstash configuration.
#
# @example Install Logstash, ensure the service is running and enabled.
#   class { 'logstash': }
#
# @example Remove Logstash.
#   class { 'logstash':
#     ensure => 'absent',
#   }
#
# @example Install everything but disable the service.
#   class { 'logstash':
#     status => 'disabled',
#   }
#
# @example Configure Logstash settings.
#   class { 'logstash':
#     settings => {
#       'http.port' => '9700',
#     }
#   }
#
# @example Configure Logstash startup options.
#   class { 'logstash':
#     startup_options => {
#       'LS_USER' => 'root',
#     }
#   }
#
# @example Set JVM memory options.
#   class { 'logstash':
#     jvm_options => [
#       '-Xms1g',
#       '-Xmx1g',
#     ]
#   }
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash(
  $ensure            = 'present',
  $status            = 'enabled',
  $restart_on_change = true,
  $auto_upgrade       = false,
  $version           = undef,
  $package_url       = undef,
  $package_name      = 'logstash',
  $download_timeout  = 600,
  $logstash_user     = 'logstash',
  $logstash_group    = 'logstash',
  $config_dir         = '/etc/logstash',
  $purge_config      = true,
  $service_provider  = undef,
  $settings          = {},
  $startup_options   = {},
  $jvm_options       = [],
  $manage_repo       = true,
  $repo_version      = '5.x',
)
{
  $home_dir = '/usr/share/logstash'

  validate_bool($auto_upgrade)
  validate_bool($restart_on_change)
  validate_bool($purge_config)
  validate_bool($manage_repo)

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if ! is_integer($download_timeout) {
    fail("\"${download_timeout}\" is not a valid number for 'download_timeout' parameter")
  }

  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }


  if ($manage_repo == true) {
    validate_string($repo_version)
    include logstash::repo
  }
  include logstash::package
  include logstash::config
  include logstash::service
}
