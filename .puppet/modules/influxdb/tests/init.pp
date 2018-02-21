# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
include influxdb

$udp_options = [
    { 'enabled'       => true,
      'bind-address'  => '":8089"',
      'database'      => '"udp_db1"',
      'batch-size'    => 10000,
      'batch-timeout' => '"1s"',
      'batch-pending' => 5,
    },
    { 'enabled'       => true,
      'bind-address'  => '":8090"',
      'database'      => '"udp_db2"',
      'batch-size'    => 10000,
      'batch-timeout' => '"1s"',
      'batch-pending' => 5,
    },
]

class {'influxdb::server':
    reporting_disabled    => true,
    http_auth_enabled     => true,
    version               => '0.9.4.2',
    shard_writer_timeout  => '10s',
    cluster_write_timeout => '10s',
    udp_options           => $udp_options,
}
