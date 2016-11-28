define filebeat::prospector (
  $ensure                = present,
  $paths                 = [],
  $exclude_files         = [],
  $encoding              = 'plain',
  $input_type            = 'log',
  $fields                = {},
  $fields_under_root     = false,
  $ignore_older          = undef,
  $close_older           = undef,
  $doc_type              = 'log',
  $scan_frequency        = '10s',
  $harvester_buffer_size = 16384,
  $tail_files            = false,
  $backoff               = '1s',
  $max_backoff           = '10s',
  $backoff_factor        = 2,
  $force_close_files     = false,
  $include_lines         = [],
  $exclude_lines         = [],
  $max_bytes             = '10485760',
  $multiline             = {},
) {

  validate_hash($fields, $multiline)
  validate_array($paths, $exclude_files, $include_lines, $exclude_lines)

  $prospector_template = $filebeat::real_version ? {
    '5' => 'prospector5.yml.erb',
    '1' => 'prospector.yml.erb',
  }

  case $::kernel {
    'Linux' : {
      file { "filebeat-${name}":
        ensure  => $ensure,
        path    => "${filebeat::config_dir}/${name}.yml",
        owner   => 'root',
        group   => 'root',
        mode    => $::filebeat::config_file_mode,
        content => template("${module_name}/${prospector_template}"),
        notify  => Service['filebeat'],
      }
    }
    'Windows' : {
      file { "filebeat-${name}":
        ensure  => $ensure,
        path    => "${filebeat::config_dir}/${name}.yml",
        content => template("${module_name}/${prospector_template}"),
        notify  => Service['filebeat'],
      }
    }
    default : {
      fail($filebeat::kernel_fail_message)
    }
  }
}
