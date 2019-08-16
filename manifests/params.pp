#
class influxdb::params {
  $version               = 'installed'
  $ensure                = 'present'
  $service_enabled       = true
  $service_ensure        = 'running'
  $manage_service        = true

  $conf_template         = 'influxdb/influxdb.conf.erb'
  $startup_conf_template = 'influxdb/influxdb_default.erb'

  $config_file           = '/etc/influxdb/influxdb.conf'

  $influxdb_stderr_log   = '/var/log/influxdb/influxd.log'
  $influxdb_stdout_log   = '/var/log/influxdb/influxd.log'
  $influxd_opts          = undef
  $manage_install        = true

  $global_config = {
    'reporting-disabled' => true,
    'bind-address'       => ':8088',
  }

  $meta_config = {
    'dir'                  => '/var/lib/influxdb/meta',
    'retention-autocreate' => true,
    'logging-enabled'      => true,
  }

  $data_config = {
    'dir'                                => '/var/lib/influxdb/data',
    'wal-dir'                            => '/var/lib/influxdb/wal',
    'trace-logging-enabled'              => false,
    'query-log-enabled'                  => true,
    'cache-max-memory-size'              => 1048576000,
    'cache-snapshot-memory-size'         => 26214400,
    'cache-snapshot-write-cold-duration' => '10m',
    'compact-full-write-cold-duration'   => '4h',
    'max-series-per-database'            => 1000000,
    'max-values-per-tag'                 => 100000,
  }
  
  $logging_config = {
    'format'        => 'auto',
    'level'         => 'warn',
    'suppress-logo' => false,
  }

  $coordinator_config = {
    'write-timeout'          => '10s',
    'max-concurrent-queries' => 0,
    'query-timeout'          => '0s',
    'log-queries-after'      => '0s',
    'max-select-point'       => 0,
    'max-select-series'      => 0,
    'max-select-buckets'     => 0,
  }

  $retention_config = {
    'enabled'        => true,
    'check-interval' => '30m',
  }

  $shard_precreation_config = {
    'enabled'        => true,
    'check-interval' => '10m',
    'advance-period' => '30m',
  }

  $monitor_config = {
    'store-enabled'  => true,
    'store-database' => '_internal',
    'store-interval' => '10s',
  }

  # NOTE: As of Influx >= 1.2 the admin section is deprecated.
  # https://docs.influxdata.com/influxdb/v1.2/administration/config/#admin
  $admin_config = {
    'enabled'           => false,
    'bind-address'      => ':8083',
    'https-enabled'     => false,
    'https-certificate' => '/etc/ssl/influxdb.pem',
  }

  $http_config = {
    'enabled'              => true,
    'bind-address'         => ':8086',
    'auth-enabled'         => false,
    'realm'                => 'InfluxDB',
    'log-enabled'          => true,
    'write-tracing'        => false,
    'pprof-enabled'        => true,
    'https-enabled'        => false,
    'https-certificate'    => '/etc/ssl/influxdb.pem',
    'https-private-key'    => '',
    'shared-sercret'       => '',
    'max-row-limit'        => 0,
    'max-connection-limit' => 0,
    'unix-socket-enabled'  => false,
    'bind-socket'          => '/var/run/influxdb.sock',
  }

  $subscriber_config = {
    'enabled'              => true,
    'http-timeout'         => '30s',
    'insecure-skip-verify' => false,
    'ca-certs'             => '',
    'write-concurrency'    => 40,
    'write-buffer-size'    => 1000,
  }

  $graphite_config = {
    'default' => {
      'enabled'           => false,
      'database'          => 'graphite',
      'retention-policy'  => '',
      'bind-address'      => ':2003',
      'protocol'          => 'tcp',
      'consistency-level' => 'one',
      'batch-size'        => 5000,
      'batch-pending'     => 10,
      'batch-timeout'     => '1s',
      'udp-read-buffer'   => 0,
      'separator'         => '.',
      'tags'              => [],
      'templates'         => [],
    }
  }

  $collectd_config = {
    'default' => {
      'enabled'          => false,
      'bind-address'     => ':25826',
      'database'         => 'collectd',
      'retention-policy' => '',
      'typesdb'          => '/usr/share/collectd/types.db',
      'batch-size'       => 5000,
      'batch-pending'    => 10,
      'batch-timeout'    => '10s',
      'read-buffer'      => 0,
    }
  }

  $opentsdb_config = {
    'default' => {
      'enabled'           => false,
      'bind-address'      => ':4242',
      'database'          => 'opentsdb',
      'retention-policy'  => '',
      'consistency-level' => 'one',
      'tls-enabled'       => false,
      'certificate'       => '/etc/ssl/influxdb.pem',
      'log-point-errors'  => true,
      'batch-size'        => 1000,
      'batch-pending'     => 5,
      'batch-timeout'     => '1s'
    }
  }

  $udp_config = {
    'default' => {
      'enabled'          => false,
      'bind-address'     => ':8089',
      'database'         => 'udp',
      'retention-policy' => '',
      'batch-size'       => 5000,
      'batch-pending'    => 10,
      'batch-timeout'    => '1s',
      'read-buffer'      => 0,
    }
  }

  $continuous_queries_config = {
    'enabled'      => true,
    'log-enabled'  => true,
    'run-interval' => '1s',
  }

  # deprecated as of 1.x?
  $hinted_handoff_config = {}

  case $::osfamily {
    'Debian': {
      $startup_conf = '/etc/default/influxdb'
      $manage_repos = false
    }
    'RedHat': {
      $startup_conf = $::operatingsystemmajrelease ? {
        /7/     => '/etc/default/influxdb',
        default => '/etc/sysconfig/influxdb'
      }
      $manage_repos = false
    }
    'Archlinux': {
      $startup_conf = '/etc/default/influxdb'
      $manage_repos = false
    }
    default: {
      fail("Unsupported managed repository for osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem},\
      module ${module_name} currently only supports managing repos for osfamily RedHat, Debian and Archlinux")
    }
  }
}
