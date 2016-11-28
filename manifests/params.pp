class filebeat::params {
  $package_ensure = present
  $manage_repo    = true
  $service_ensure = running
  $service_enable = true
  $spool_size     = 2048
  $idle_timeout   = '5s'
  $publish_async  = false
  $shutdown_timeout  = 0
  $beat_name         = $::fqdn
  $tags              = []
  $queue_size        = 1000
  $max_procs         = undef
  $registry_file  = '.filebeat'
  $config_dir_mode = '0755'
  $config_file_mode = '0644'
  $purge_conf_dir = true
  $fields         = {}
  $fields_under_root = false
  $outputs        = {}
  $shipper        = {}
  $logging        = {}
  $run_options    = {}
  $use_generic_template = false

  # These are irrelevant as long as the template is set based on the major_version parameter
  # if versioncmp('1.9.1', $::rubyversion) > 0 {
  #   $conf_template = "${module_name}/filebeat.yml.ruby18.erb"
  # } else {
  #   $conf_template = "${module_name}/filebeat.yml.erb"
  # }
  #
  case $::kernel {
    'Linux'   : {
      $config_file     = '/etc/filebeat/filebeat.yml'
      $config_dir      = '/etc/filebeat/conf.d'

      # These parameters are ignored if/until tarball installs are supported in Linux
      $tmp_dir         = '/tmp'
      $install_dir     = undef
      $download_url    = undef
      case $::osfamily {
        'RedHat': {
          $service_provider = 'redhat'
        }
        default: {
          $service_provider = undef
        }
      }
    }

    'Windows' : {
      $config_file      = 'C:/Program Files/Filebeat/filebeat.yml'
      $config_dir       = 'C:/Program Files/Filebeat/conf.d'
      $download_url     = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.0.1-windows-x86_64.zip'
      $install_dir      = 'C:/Program Files'
      $tmp_dir          = 'C:/Windows/Temp'
      $service_provider = undef
    }

    default : {
      fail("${::kernel} is not supported by filebeat.")
    }
  }
}
