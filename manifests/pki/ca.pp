# == Class: icinga2::pki::ca
#
# This class provides multiple ways to create the CA used by Icinga 2. By default it will create
# a CA by using the icinga2 CLI. If you want to use your own CA you will either have to transfer
# it by using a file resource or you can set the content of your certificat and key in this class.
#
# === Parameters
#
# [*ca_cert*]
#   Content of the CA certificate. If this is unset, a certificate will be generated with the
#   Icinga 2 CLI.
#
# [*ca_key*]
#   Content of the CA key. If this is unset, a key will be generated with the Icinga 2 CLI.
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
# [*ssl_csr_path*]
#   Location of the certificate signing request. Default depends on platform:
#   /etc/icinga2/pki/NodeName.csr on Linux
#   C:/ProgramData/icinga2/etc/icinga2/pki/NodeName.csr on Windows
#   The Value of NodeName comes from the corresponding constant.
#
# [*ssl_cacert_path*]
#   Location of the CA certificate. Default is:
#   /etc/icinga2/pki/ca.crt on Linux
#   C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt on Windows
#
# === Examples
#
# Let Icinga 2 generate a CA for you:
#
# include icinga2
# class { 'icinga2::pki::ca': }
#
# Set the content of CA certificate and key:
#
# include icinga2
# class { 'icinga2::pki::ca':
#   ca_cert => '-----BEGIN CERTIFICATE----- ...',
#   ca_key  => '-----BEGIN RSA PRIVATE KEY----- ...',
# }
#
#
class icinga2::pki::ca(
  $ca_cert         = undef,
  $ca_key          = undef,
  $ssl_key_path    = undef,
  $ssl_cert_path   = undef,
  $ssl_csr_path    = undef,
  $ssl_cacert_path = undef,
) {

  include ::icinga2::params
  require ::icinga2::config

  $bin_dir   = $::icinga2::params::bin_dir
  $ca_dir    = $::icinga2::params::ca_dir
  $pki_dir   = $::icinga2::params::pki_dir
  $user      = $::icinga2::params::user
  $group     = $::icinga2::params::group
  $node_name = $::icinga2::_constants['NodeName']

  File {
    owner => $user,
    group => $group,
  }

  Exec {
    path => $bin_dir,
  }

  if $ssl_key_path {
    validate_absolute_path($ssl_key_path)
    $_ssl_key_path = $ssl_key_path }
  else {
    $_ssl_key_path = "${pki_dir}/${node_name}.key" }
  if $ssl_cert_path {
    validate_absolute_path($ssl_cert_path)
    $_ssl_cert_path = $ssl_cert_path }
  else {
    $_ssl_cert_path = "${pki_dir}/${node_name}.crt" }
  if $ssl_csr_path {
    validate_absolute_path($ssl_csr_path)
    $_ssl_csr_path = $ssl_csr_path }
  else {
    $_ssl_csr_path = "${pki_dir}/${node_name}.csr" }
  if $ssl_cacert_path {
    validate_absolute_path($ssl_cacert_path)
    $_ssl_cacert_path = $ssl_cacert_path }
  else {
    $_ssl_cacert_path = "${pki_dir}/ca.crt" }

  if !$ca_cert or !$ca_key {
    $path = $::osfamily ? {
      'windows' => 'C:/ProgramFiles/ICINGA2/sbin',
      default   => '/bin:/usr/bin:/sbin:/usr/sbin',
    }

    exec { 'create-icinga2-ca':
      command => 'icinga2 pki new-ca',
      creates => "${ca_dir}/ca.crt",
      before  => File[$_ssl_cacert_path],
      notify  => Class['::icinga2::service'],
    }
  } else {
    validate_string($ca_cert)
    validate_string($ca_key)

    if $::osfamily == 'windows' {
      $_ca_dir_mode = undef
      $_ca_cert      = regsubst($ca_cert, '\n', "\r\n", 'EMG')
      $_ca_key_mode = undef
      $_ca_key      = regsubst($ca_key, '\n', "\r\n", 'EMG')
    } else {
      $_ca_dir_mode = '0700'
      $_ca_cert     = $ca_cert
      $_ca_key_mode = '0600'
      $_ca_key      = $ca_key
    }

    file { $ca_dir:
      ensure => directory,
      mode   => $_ca_dir_mode,
    }

    file { "${ca_dir}/ca.crt":
      ensure  => file,
      content => $_ca_cert,
      tag     => 'icinga2::config::file',
      before  => File[$_ssl_cacert_path],
    }

    file { "${ca_dir}/ca.key":
      ensure  => file,
      mode    => $_ca_key_mode,
      content => $_ca_key,
      tag     => 'icinga2::config::file',
    }
  }

  file { $_ssl_cacert_path:
    ensure => file,
    source => "${ca_dir}/ca.crt",
  }

  exec { 'icinga2 pki create certificate signing request':
    command => "icinga2 pki new-cert --cn '${node_name}' --key '${_ssl_key_path}' --csr '${_ssl_csr_path}'",
    creates => $_ssl_key_path,
    require => File[$_ssl_cacert_path]
  }

  -> file { $_ssl_key_path:
    ensure => file,
    mode   => '0600',
  }

  exec { 'icinga2 pki sign certificate':
    command     => "icinga2 pki sign-csr --csr '${_ssl_csr_path}' --cert '${_ssl_cert_path}'",
    subscribe   => Exec['icinga2 pki create certificate signing request'],
    refreshonly => true,
    notify      => Class['::icinga2::service'],
  }

  -> file {
    $_ssl_cert_path:
      ensure => file;
    $_ssl_csr_path:
      ensure => absent;
  }
}
