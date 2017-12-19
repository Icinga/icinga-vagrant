# == Class: icinga2::feature::api
#
# This module configures the Icinga 2 feature api.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature api, absent disabled it. Defaults to present.
#
# [*pki*]
#   Provides multiple sources for the certificate, key and ca. Valid parameters are 'puppet' or 'none'.
#   - puppet: Copies the key, cert and CAcert from the Puppet ssl directory to the pki directory
#             /etc/icinga2/pki on Linux and C:/ProgramData/icinga2/etc/icinga2/pki on Windows.
#   - icinga2: Uses the icinga2 CLI to generate a Certificate and Key The ticket is generated on the
#              Puppetmaster by using the configured 'ticket_salt' in a custom function.
#   - none: Does nothing and you either have to manage the files yourself as file resources
#           or use the ssl_key, ssl_cert, ssl_cacert parameters. Defaults to puppet.
#   - ca: Includes the '::icinga2::pki::ca' class to generate a fresh CA and generates an SSL certificate and
#         key signed by this new CA.
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
# [*ssl_key*]
#   The private key in a base64 encoded string to store in pki directory, file is stored to
#   path specified in ssl_key_path. This parameter requires pki to be set to 'none'.
#
# [*ssl_cert*]
#   The certificate in a base64 encoded string to store in pki directory, file is  stored to
#   path specified in ssl_cert_path. This parameter requires pki to be set to 'none'.
#
# [*ssl_cacert*]
#   The CA root certificate in a base64 encoded string to store in pki directory, file is stored
#   to path specified in ssl_cacert_path. This parameter requires pki to be set to 'none'.
#
# [*accept_config*]
#   Accept zone configuration. Defaults to false.
#
# [*accept_commands*]
#   Accept remote commands. Defaults to false.
#
# [*ca_host*]
#   This host will be connected to request the certificate. Set this if you use the icinga2 pki.
#
# [*ca_port*]
#   Port of the 'ca_host'. Defaults to 5665
#
# [*ticket_salt*]
#   Salt to use for ticket generation. The salt is stored to api.conf if none or ca is chosen for pki.
#   Defaults to constant TicketSalt.
#
# [*endpoints*]
#   Hash to configure endpoint objects. Defaults to { 'NodeName' => {} }.
#   NodeName is a icnga2 constant.
#
# [*zones*]
#   Hash to configure zone objects. Defaults to { 'ZoneName' => {'endpoints' => ['NodeName']} }.
#   ZoneName and NodeName are icinga2 constants.
#
# [*ssl_protocolmin*]
#   Minimal TLS version to require. Default undef (e.g. "TLSv1.2")
#
# [*ssl_cipher_list*]
#   List of allowed TLS ciphers, to finetune encryption. Default undef (e.g. "HIGH:MEDIUM:!aNULL:!MD5:!RC4")
#
# [*bind_host*]
#   The IP address the api listener will be bound to. (e.g. 0.0.0.0)
#
# [*bind_port*]
#   The port the api listener will be bound to. (e.g. 5665)
#
# === Variables
#
# [*node_name*]
#   Certname and Keyname based on constant NodeName.
#
# [*_ssl_key_path*]
#   Validated path to private key file.
#
# [*_ssl_cert_path*]
#   Validated path to certificate file.
#
# [*_ssl_casert_path*]
#   Validated path to root CA certificate file.
#
# === Examples
#
# Use the puppet certificates and key copy these files to the 'pki' directory
# named to 'hostname.key', 'hostname.crt' and 'ca.crt' if the contant NodeName
# is set to 'hostname'.
#
#   include ::icinga2::feature::api
#
# To use your own certificates and key as file resources if the contant NodeName is
# set to fqdn (default) do:
#
#   class { 'icinga2::feature::api':
#     pki => 'none',
#   }
#
#   File {
#     owner => 'icinga',
#     group => 'icinga',
#   }
#
#   file { "/etc/icinga2/pki/${::fqdn}.key":
#     ensure => file,
#     tag    => 'icinga2::config::file,
#     source => "puppet:///modules/profiles/private_keys/${::fqdn}.key",
#   }
#   ...
#
# If you like to manage the certificates and the key as strings in base64 encoded format:
#
#   class { 'icinga2::feature::api':
#     pki         => 'none',
#     ssl_cacert  => '-----BEGIN CERTIFICATE----- ...',
#     ssl_key     => '-----BEGIN RSA PRIVATE KEY----- ...',
#     ssl_cert    => '-----BEGIN CERTIFICATE----- ...',
#   }
#
#
class icinga2::feature::api(
  $ensure          = present,
  $pki             = 'puppet',
  $ssl_key_path    = undef,
  $ssl_cert_path   = undef,
  $ssl_csr_path    = undef,
  $ssl_cacert_path = undef,
  $accept_config   = false,
  $accept_commands = false,
  $ca_host         = undef,
  $ca_port         = 5665,
  $ticket_salt     = 'TicketSalt',
  $endpoints       = { 'NodeName' => {} },
  $zones           = { 'ZoneName' => { endpoints => [ 'NodeName' ] } },
  $ssl_key         = undef,
  $ssl_cert        = undef,
  $ssl_cacert      = undef,
  $ssl_protocolmin = undef,
  $ssl_cipher_list = undef,
  $bind_host       = undef,
  $bind_port       = undef,
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  # pki directory must exists and icinga binary is required for icinga2 pki
  require ::icinga2::install

  $icinga2_bin   = $::icinga2::params::icinga2_bin
  $bin_dir       = $::icinga2::params::bin_dir
  $conf_dir      = $::icinga2::params::conf_dir
  $pki_dir       = $::icinga2::params::pki_dir
  $ca_dir        = $::icinga2::params::ca_dir
  $user          = $::icinga2::params::user
  $group         = $::icinga2::params::group
  $node_name     = $::icinga2::_constants['NodeName']
  $_ssl_key_mode = $::osfamily ? {
    'windows' => undef,
    default   => '0600',
  }
  $_notify       = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  File {
    owner => $user,
    group => $group,
  }

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_re($pki, [ '^puppet$', '^none$', '^icinga2', '^ca' ],
    "${pki} isn't supported. Valid values are 'puppet', 'none', 'icinga2' and 'ca (deprecated)'.")
  validate_bool($accept_config)
  validate_bool($accept_commands)
  validate_string($ticket_salt)
  validate_hash($endpoints)
  validate_hash($zones)

  # Set defaults for certificate stuff and/or do validation
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

  if $ssl_protocolmin {
    validate_string($ssl_protocolmin)
  }
  if $ssl_cipher_list {
    validate_string($ssl_cipher_list)
  }
  if $bind_host {
    validate_string($bind_host)
  }
  if $bind_port {
    validate_integer($bind_port)
  }



  # handle the certificate's stuff
  case $pki {
    'puppet': {
      $_ticket_salt = undef

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
      # non means you manage the CA on your own and so
      # the salt has to be stored in api.conf
      $_ticket_salt = $ticket_salt

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

    'icinga2': {
      $_ticket_salt = undef

      validate_string($ca_host)
      validate_integer($ca_port)

      $ticket_id = icinga2_ticket_id($node_name, $ticket_salt)
      $trusted_cert = "${pki_dir}/trusted-cert.crt"

      Exec {
        path => $bin_dir,
        notify  => Class['::icinga2::service'],
      }

      exec { 'icinga2 pki create key':
        command => "${icinga2_bin} pki new-cert --cn ${node_name} --key ${_ssl_key_path} --cert ${_ssl_cert_path}",
        creates => $_ssl_key_path,
      }

      -> exec { 'icinga2 pki get trusted-cert':
        command => "${icinga2_bin} pki save-cert --host ${ca_host} --port ${ca_port} --key ${_ssl_key_path} --cert ${_ssl_cert_path} --trustedcert ${trusted_cert}",
        creates => $trusted_cert,
      }

      -> exec { 'icinga2 pki request':
        command => "${icinga2_bin} pki request --host ${ca_host} --port ${ca_port} --ca ${_ssl_cacert_path} --key ${_ssl_key_path} --cert ${_ssl_cert_path} --trustedcert ${trusted_cert} --ticket ${ticket_id}",
        creates => $_ssl_cacert_path,
      }
    } # icinga2

    'ca': {
      $_ticket_salt = $ticket_salt
      class { '::icinga2::pki::ca': }

      warning('This parameter is deprecated and will be removed in future versions! Please use ::icinga2::pki::ca instead')
    } # ca
  } # case pki

  # compose attributes
  $attrs = {
    cert_path       => $_ssl_cert_path,
    key_path        => $_ssl_key_path,
    ca_path         => $_ssl_cacert_path,
    accept_commands => $accept_commands,
    accept_config   => $accept_config,
    ticket_salt     => $_ticket_salt,
    tls_protocolmin => $ssl_protocolmin,
    cipher_list     => $ssl_cipher_list,
    bind_host       => $bind_host,
    bind_port       => $bind_port,
  }

  # create endpoints and zones
  create_resources('icinga2::object::endpoint', $endpoints)
  create_resources('icinga2::object::zone', $zones)

  # create object
  icinga2::object { 'icinga2::object::ApiListener::api':
    object_name => 'api',
    object_type => 'ApiListener',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/api.conf",
    order       => '10',
    notify      => $_notify,
  }

  # manage feature
  icinga2::feature { 'api':
    ensure      => $ensure,
  }
}
