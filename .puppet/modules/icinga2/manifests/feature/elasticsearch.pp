# == Class: icinga2::feature::elasticsearch
#
# This module configures the Icinga 2 feature elasticsearch.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature elasticsearch, absent disables it. Defaults to present.
#
# [*host*]
#    Elasticsearch host address. Defaults to 127.0.0.1.
#
# [*port*]
#    Elasticsearch HTTP port. Defaults to 9200.
#
# [*index*]
#    Elasticsearch index name. Defaults to icinga2.
#
# [*username*]
#    Elasticsearch user name. Defaults to undef.
#
# [*password*]
#    Elasticsearch user password. Defaults to undef.
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
# [*enable_send_perfdata*]
#    Whether to send check performance data metrics. Defaults to false.
#
# [*flush_interval*]
#    How long to buffer data points before transferring to Elasticsearch. Defaults to 10s.
#
# [*flush_threshold*]
#    How many data points to buffer before forcing a transfer to Elasticsearch. Defaults to 1024.
#
# === Example
#
# class { 'icinga2::feature::elasticsearch':
#   host     => "10.10.0.15",
#   index    => "icinga2"
# }
#
#
class icinga2::feature::elasticsearch(
  $ensure                 = present,
  $host                   = '127.0.0.1',
  $port                   = 9200,
  $index                  = 'icinga2',
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
  $enable_send_perfdata   = false,
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
  $ssl_dir       = "${::icinga2::params::pki_dir}/elasticsearch"
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
  validate_string($index)
  validate_string($username)
  validate_string($password)
  validate_bool($enable_ssl)
  validate_re($pki, [ '^puppet$', '^none$' ],
    "${pki} isn't supported. Valid values are 'puppet' and 'none'.")
  validate_bool($enable_send_perfdata)
  validate_re($flush_interval, '^\d+[ms]*$')
  validate_integer($flush_threshold)

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
      enable_tls  => $enable_ssl,
      ca_path     => $_ssl_cacert_path,
      cert_path   => $_ssl_cert_path,
      key_path    => $_ssl_key_path,
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
        if $key_path {
          $_key_path = $::osfamily ? {
            'windows' => regsubst($ssl_key, '\n', "\r\n", 'EMG'),
            default   => $key_path,
          }

          file { $_ssl_key_path:
            ensure  => file,
            mode    => $_ssl_key_mode,
            content => $_key_path,
            tag     => 'icinga2::config::file',
          }
        }

        if $cert_path {
          $_cert_path = $::osfamily ? {
            'windows' => regsubst($cert_path, '\n', "\r\n", 'EMG'),
            default   => $cert_path,
          }

          file { $_ssl_cert_path:
            ensure  => file,
            content => $_cert_path,
            tag     => 'icinga2::config::file',
          }
        }

        if $ssl_cacert {
          $_ca_path = $::osfamily ? {
            'windows' => regsubst($ca_path, '\n', "\r\n", 'EMG'),
            default   => $ca_path,
          }

          file { $_ssl_cacert_path:
            ensure  => file,
            content => $_ca_path,
            tag     => 'icinga2::config::file',
          }
        }
      } # none
    } # case pki
  } # enable_ssl
  else {
    $attrs_ssl = { enable_tls  => $enable_ssl }
  }

  $attrs = {
    host                   => $host,
    port                   => $port,
    index                  => $index,
    username               => $username,
    password               => $password,
    enable_send_perfdata   => $enable_send_perfdata,
    flush_interval         => $flush_interval,
    flush_threshold        => $flush_threshold,
  }

  # create object
  icinga2::object { 'icinga2::object::ElasticsearchWriter::elasticsearch':
    object_name => 'elasticsearch',
    object_type => 'ElasticsearchWriter',
    attrs       => delete_undef_values(merge($attrs, $attrs_ssl)),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/elasticsearch.conf",
    notify      => $_notify,
    order       => '10',
  }

  # import library 'perfdata'
  concat::fragment { 'icinga2::feature::elasticsearch':
    target  => "${conf_dir}/features-available/elasticsearch.conf",
    content => "library \"perfdata\"\n\n",
    order   => '05',
  }

  icinga2::feature { 'elasticsearch':
    ensure => $ensure,
  }
}
