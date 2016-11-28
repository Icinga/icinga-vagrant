# This class installs the Elastic filebeat log shipper and
# helps manage which files are shipped
#
# @example
# class { 'filebeat':
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param major_version [String] The major version of filebeat to install. Should be either undef, 1, or
# 5. (default 5 if 1 not already installed)
# @param package_ensure [String] The ensure parameter for the filebeat package (default: present)
# @param manage_repo [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
# @param service_ensure [String] The ensure parameter on the filebeat service (default: running)
# @param service_enable [String] The enable parameter on the filebeat service (default: true)
# @param spool_size [Integer] How large the spool should grow before being flushed to the network (default: 2048)
# @param idle_timeout [String] How often the spooler should be flushed even if spool size isn't reached (default: 5s)
# @param publish_async [Boolean] If set to true filebeat will publish while preparing the next batch of lines to send (defualt: false)
# @param registry_file [String] The registry file used to store positions, absolute or relative to working directory (default .filebeat)
# @param config_dir [String] The directory where prospectors should be defined (default: /etc/filebeat/conf.d)
# @param config_dir_mode [String] The unix permissions mode set on the configuration directory (default: 0755)
# @param config_file_mode [String] The unix permissions mode set on configuration files (default: 0644)
# @param purge_conf_dir [Boolean] Should files in the prospector configuration directory not managed by puppet be automatically purged
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the filebeat config (see documentation)
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the filebeat config (see documentation)
# @param conf_template [String] The configuration template to use to generate the main filebeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install filebeat (windows only)
# @param install_dir [String] Where filebeat should be installed (windows only)
# @param tmp_dir [String] Where filebeat should be temporarily downloaded to so it can be installed (windows only)
# @param use_generic_template [Boolean] Use a more generic version of the configuration template. The generic template is more
#  future proof (if types are correct), but looks very different than the example file (default: false)
# @param shutdown_timeout [String] How long filebeat waits on shutdown for the publisher to finish sending events
# @param beat_name [String] The name of the beat shipper (default: hostname)
# @param tags [Array] A list of tags that will be included with each published transaction
# @param queue_size [String] The internal queue size for events in the pipeline
# @param max_procs [Number] The maximum number of CPUs that can be simultaneously used
# @param fields [Hash] Optional fields that should be added to each event output
# @param fields_under_root [Boolean] If set to true, custom fields are stored in the top level instead of under fields
# @param prospectors [Hash] Prospectors that will be created. Commonly used to create prospectors using hiera
# @param prospectors_merge [Boolean] Whether $prospectors should merge all hiera sources, or use simple automatic parameter lookup
class filebeat (
  $major_version        = undef,
  $package_ensure       = $filebeat::params::package_ensure,
  $manage_repo          = $filebeat::params::manage_repo,
  $service_ensure       = $filebeat::params::service_ensure,
  $service_enable       = $filebeat::params::service_enable,
  $service_provider     = $filebeat::params::service_provider,
  $spool_size           = $filebeat::params::spool_size,
  $idle_timeout         = $filebeat::params::idle_timeout,
  $publish_async        = $filebeat::params::publish_async,
  $registry_file        = $filebeat::params::registry_file,
  $config_file          = $filebeat::params::config_file,
  $config_dir_mode      = $filebeat::params::config_dir_mode,
  $config_dir           = $filebeat::params::config_dir,
  $config_file_mode     = $filebeat::params::config_file_mode,
  $purge_conf_dir       = $filebeat::params::purge_conf_dir,
  $outputs              = $filebeat::params::outputs,
  $shipper              = $filebeat::params::shipper,
  $logging              = $filebeat::params::logging,
  $run_options          = $filebeat::params::run_options,
  $conf_template        = undef,
  $download_url         = $filebeat::params::download_url,
  $install_dir          = $filebeat::params::install_dir,
  $tmp_dir              = $filebeat::params::tmp_dir,
  #### v5 only ####
  $use_generic_template = $filebeat::params::use_generic_template,
  $shutdown_timeout     = $filebeat::params::shutdown_timeout,
  $beat_name            = $filebeat::params::beat_name,
  $tags                 = $filebeat::params::tags,
  $queue_size           = $filebeat::params::queue_size,
  $max_procs            = $filebeat::params::max_procs,
  $fields               = $filebeat::params::fields,
  $fields_under_root    = $filebeat::params::fields_under_root,
  #### End v5 onlly ####
  $prospectors          = {},
  $prospectors_merge    = false,
) inherits filebeat::params {

  $kernel_fail_message = "${::kernel} is not supported by filebeat."

  validate_bool($manage_repo, $prospectors_merge)

  if $major_version == undef and $::filebeat_version == undef {
    $real_version = '5'
  } elsif $major_version == undef and versioncmp($::filebeat_version, '5.0.0') >= 0 {
    $real_version = '5'
  } elsif $major_version == undef and versioncmp($::filebeat_version, '5.0.0') < 0 {
    $real_version = '1'
  } else {
    $real_version = $major_version
  }

  if $conf_template != undef {
    $real_conf_template = $conf_template
  } elsif $real_version == '1' {
    if versioncmp('1.9.1', $::rubyversion) > 0 {
      $real_conf_template = "${module_name}/filebeat.yml.ruby18.erb"
    } else {
      $real_conf_template = "${module_name}/filebeat.yml.erb"
    }
  } elsif $real_version == '5' {
    if $use_generic_template {
      $real_conf_template = "${module_name}/filebeat.yml.erb"
    } else {
      $real_conf_template = "${module_name}/filebeat5.yml.erb"
    }
  }


  if $prospectors_merge {
    $prospectors_final = hiera_hash('filebeat::prospectors', $prospectors)
  } else {
    $prospectors_final = $prospectors
  }

  if $config_file != $filebeat::params::config_file {
    warning('You\'ve specified a non-standard config_file location - filebeat may fail to start unless you\'re doing something to fix this')
  }

  validate_hash($outputs, $logging, $prospectors_final)
  validate_string($idle_timeout, $registry_file, $config_dir, $package_ensure)

  if $package_ensure == '1.0.0-beta4' or $package_ensure == '1.0.0-rc1' {
    fail('Filebeat versions 1.0.0-rc1 and before are unsupported because they don\'t parse normal YAML headers')
  }

  anchor { 'filebeat::begin': } ->
  class { 'filebeat::install': } ->
  class { 'filebeat::config': } ->
  class { 'filebeat::service': } ->
  anchor { 'filebeat::end': }

  if !empty($prospectors_final) {
    create_resources('filebeat::prospector', $prospectors_final)
  }
}
