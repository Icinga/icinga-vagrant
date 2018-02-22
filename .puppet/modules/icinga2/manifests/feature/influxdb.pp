# == Class: icinga2::feature::influxdb
#
# This module configures the Icinga 2 feature influxdb.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature influxdb, absent disables it. Defaults to present.
#
# [*host*]
#    InfluxDB host address. Defaults to 127.0.0.1.
#
# [*port*]
#    InfluxDB HTTP port. Defaults to 8086.
#
# [*database*]
#    InfluxDB database name. Defaults to icinga2.
#
# [*username*]
#    InfluxDB user name. Defaults to undef.
#
# [*password*]
#    InfluxDB user password. Defaults to undef.
#
# [*enable_ssl*]
#    Either enable or disable SSL. Other SSL parameters are only affected if this is set to 'true'.
#    Defaults to 'false'.
#
# [*pki*]
#   Provides multiple sources for the certificate, key and ca. Valid parameters are 'puppet' or 'none'.
#   'puppet' copies the key, cert and CAcert from the Puppet ssl directory to the pki directory
#   /etc/icinga2/pki on Linux and C:/ProgramData/icinga2/etc/icinga2/pki on Windows.
#   'none' does nothing and you either have to manage the files yourself as file resources
#   or use the ssl_key, ssl_cert, ssl_cacert parameters. Defaults to puppet.
#
# [*ssl_key_path*]
#   Location of the private key. Default depends on platform:
#   /etc/icinga2/pki/NodeName.key on Linux
#   C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.key on Windows
#   The Value of NodeName comes from the corresponding constant.
#
# [*ssl_cert_path*]
#   Location of the certificate. Default depends on platform:
#   /etc/icinga2/pki/NodeName.crt on Linux
#   C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.crt on Windows
#   The Value of NodeName comes from the corresponding constant.
#
# [*ssl_cacert_path*]
#   Location of the CA certificate. Default is:
#   /etc/icinga2/pki/ca.crt on Linux
#   C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt on Windows
#
# [*ssl_key*]
#   The private key in a base64 encoded string to store in pki directory, file is stored to
#   path spicified in ssl_key_path. This parameter requires pki to be set to 'none'.
#
# [*ssl_cert*]
#   The certificate in a base64 encoded string to store in pki directory, file is  stored to
#   path spicified in ssl_cert_path. This parameter requires pki to be set to 'none'.
#
# [*ssl_cacert*]
#   The CA root certificate in a base64 encoded string to store in pki directory, file is stored
#   to path spicified in ssl_cacert_path. This parameter requires pki to be set to 'none'.
#
# [*host_measurement*]
#    The value of this is used for the measurement setting in host_template. Defaults to  '$host.check_command$'
#
# [*host_tags*]
#    Tags defined in this hash will be set in the host_template.
#
#  [*service_measurement*]
#    The value of this is used for the measurement setting in host_template. Defaults to  '$service.check_command$'
#
# [*service_tags*]
#    Tags defined in this hash will be set in the service_template.
#
# [*enable_send_thresholds*]
#    Whether to send warn, crit, min & max tagged data. Defaults to false.
#
# [*enable_send_metadata*]
#    Whether to send check metadata e.g. states, execution time, latency etc. Defaults to false.
#
# [*flush_interval*]
#    How long to buffer data points before transfering to InfluxDB. Defaults to 10s.
#
# [*flush_threshold*]
#    How many data points to buffer before forcing a transfer to InfluxDB. Defaults to 1024.
#
# === Example
#
# class { 'icinga2::feature::influxdb':
#   host     => "10.10.0.15",
#   username => "icinga2",
#   password => "supersecret",
#   database => "icinga2"
# }
#
#
class icinga2::feature::influxdb(
  $ensure                 = present,
  $host                   = '127.0.0.1',
  $port                   = 8086,
  $database               = 'icinga2',
  $username               = undef,
  $password               = undef,
  $enable_ssl             = false,
  $pki                    = 'puppet',
  $ssl_key_path           = undef,
  $ssl_cert_path          = undef,
  $ssl_cacert_path        = undef,
  $ssl_key                = undef,
  $ssl_cert               = undef,
  $ssl_cacert             = undef,
  $host_measurement       = '$host.check_command$',
  $host_tags              = { hostname => '$host.name$' },
  $service_measurement    = '$service.check_command$',
  $service_tags           = { hostname => '$host.name$', service => '$service.name$' },
  $enable_send_thresholds = false,
  $enable_send_metadata   = false,
  $flush_interval         = '10s',
  $flush_threshold        = 1024
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $user          = $::icinga2::params::user
  $group         = $::icinga2::params::group
  $node_name     = $::icinga2::_constants['NodeName']
  $conf_dir      = $::icinga2::params::conf_dir
  $ssl_dir       = "${::icinga2::params::pki_dir}/influxdb"
  $_ssl_key_mode = $::kernel ? {
    'windows' => undef,
    default   => '0600',
  }
  $_notify       = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  File {
    owner   => $user,
    group   => $group,
  }

  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($host)
  validate_integer($port)
  validate_string($database)
  validate_string($username)
  validate_string($password)
  validate_bool($enable_ssl)
  validate_re($pki, [ '^puppet$', '^none$' ],
    "${pki} isn't supported. Valid values are 'puppet' and 'none'.")
  validate_string($host_measurement)
  validate_hash($host_tags)
  validate_string($service_measurement)
  validate_hash($service_tags)
  validate_bool($enable_send_thresholds)
  validate_bool($enable_send_metadata)
  validate_re($flush_interval, '^\d+[ms]*$')
  validate_integer($flush_threshold)

  $host_template = { measurement => $host_measurement, tags => $host_tags }
  $service_template = { measurement => $service_measurement, tags => $service_tags}

  # Set defaults for certificate stuff and/or do validation
  if $ssl_key_path {
    validate_absolute_path($ssl_key_path)
    $_ssl_key_path = $ssl_key_path }
  else {
    $_ssl_key_path = "${ssl_dir}/${node_name}.key" }
  if $ssl_cert_path {
    validate_absolute_path($ssl_cert_path)
    $_ssl_cert_path = $ssl_cert_path }
  else {
    $_ssl_cert_path = "${ssl_dir}/${node_name}.crt" }
  if $ssl_cacert_path {
    validate_absolute_path($ssl_cacert_path)
    $_ssl_cacert_path = $ssl_cacert_path }
  else {
    $_ssl_cacert_path = "${ssl_dir}/ca.crt" }

  if $enable_ssl {
    $attrs_ssl = {
      ssl_enable  => $enable_ssl,
      ssl_ca_cert => $_ssl_cacert_path,
      ssl_cert    => $_ssl_cert_path,
      ssl_key     => $_ssl_key_path,
    }

    file { $ssl_dir:
      ensure => directory,
    }

    case $pki {
      'puppet': {
        file { $_ssl_key_path:
          ensure => file,
          mode   => $_ssl_key_mode,
          source => $::icinga2_puppet_hostprivkey,
          tag    => 'icinga2::config::file',
        }

        file { $_ssl_cert_path:
          ensure => file,
          source => $::icinga2_puppet_hostcert,
          tag    => 'icinga2::config::file',
        }

        file { $_ssl_cacert_path:
          ensure => file,
          source => $::icinga2_puppet_localcacert,
          tag    => 'icinga2::config::file',
        }
      } # puppet

      'none': {
        if $ssl_key {
          $_ssl_key = $::osfamily ? {
            'windows' => regsubst($ssl_key, '\n', "\r\n", 'EMG'),
            default   => $ssl_key,
          }

          file { $_ssl_key_path:
            ensure  => file,
            mode    => $_ssl_key_mode,
            content => $_ssl_key,
            tag     => 'icinga2::config::file',
          }
        }

        if $ssl_cert {
          $_ssl_cert = $::osfamily ? {
            'windows' => regsubst($ssl_cert, '\n', "\r\n", 'EMG'),
            default   => $ssl_cert,
          }

          file { $_ssl_cert_path:
            ensure  => file,
            content => $_ssl_cert,
            tag     => 'icinga2::config::file',
          }
        }

        if $ssl_cacert {
          $_ssl_cacert = $::osfamily ? {
            'windows' => regsubst($ssl_cacert, '\n', "\r\n", 'EMG'),
            default   => $ssl_cacert,
          }

          file { $_ssl_cacert_path:
            ensure  => file,
            content => $_ssl_cacert,
            tag     => 'icinga2::config::file',
          }
        }
      } # none
    } # case pki
  } # enable_ssl
  else {
    $attrs_ssl = { ssl_enable  => $enable_ssl }
  }

  $attrs = {
    host                   => $host,
    port                   => $port,
    database               => $database,
    username               => $username,
    password               => $password,
    host_template          => $host_template,
    service_template       => $service_template,
    enable_send_thresholds => $enable_send_thresholds,
    enable_send_metadata   => $enable_send_metadata,
    flush_interval         => $flush_interval,
    flush_threshold        => $flush_threshold,
  }

  # create object
  icinga2::object { 'icinga2::object::InfluxdbWriter::influxdb':
    object_name => 'influxdb',
    object_type => 'InfluxdbWriter',
    attrs       => delete_undef_values(merge($attrs, $attrs_ssl)),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/influxdb.conf",
    notify      => $_notify,
    order       => '10',
  }

  # import library 'perfdata'
  concat::fragment { 'icinga2::feature::influxdb':
    target  => "${conf_dir}/features-available/influxdb.conf",
    content => "library \"perfdata\"\n\n",
    order   => '05',
  }

  icinga2::feature { 'influxdb':
    ensure => $ensure,
  }
}
