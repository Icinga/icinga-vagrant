# == Define: icingaweb2::module::puppetdb::certificate
#
# Install a certificate for the Icinga Web 2 puppetdb module. This is a public defined type.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*ssl_key*]
#   The combined key in a base64 encoded string.
#
# [*ssl_cacert*]
#   The CA root certificate in a base64 encoded string.
#
# === Examples
#
# It is advised to read about the certiciates first at
# https://github.com/Icinga/icingaweb2-module-puppetdb/blob/master/doc/01-Installation.md
#
# You can set up indiviual certificates for the Icinga Web 2 director puppetdb module
# to talk to you director like this
#
#   icingaweb2::module::puppetdb::certificate { 'mypuppetdbhost.example.com':
#     ssl_cacert  => '-----BEGIN CERTIFICATE----- ...',
#     ssl_key     => '-----BEGIN RSA PRIVATE KEY----- ...',
#   }
#
# That will install the following files with the specified contents
# cacert: /etc/icingaweb2/module/puppetdb/ssl/mypuppetdbhost.example.com/certs/ca.pem
# ssl_key: /etc/icingaweb2/module/puppetdb/ssl/mypuppetdbhost.example.com/private_keys/mypuppetdbhost.example.com_combined.pem
#
# Make sure you pass the contents combination of the private and key!
#
define icingaweb2::module::puppetdb::certificate(
  String                    $ssl_key,
  String                    $ssl_cacert,
  Enum['absent', 'present'] $ensure = 'present',
){
  assert_private("You're not supposed to use this defined type manually.")

  $certificate_dir = "${::icingaweb2::module::puppetdb::ssl_dir}/${title}"
  $conf_user       = $::icingaweb2::conf_user
  $conf_group      = $::icingaweb2::params::conf_group

  File {
    owner => $conf_user,
    group => $conf_group,
    mode  => '0740',
  }

  if $ensure == 'present' {
    $ensure_dir = 'directory'
  } else {
    $ensure_dir = 'absent'
  }

  file { [$certificate_dir, "${certificate_dir}/private_keys", "${certificate_dir}/certs"]:
    ensure  => $ensure_dir,
    purge   => true,
    force   => true,
    recurse => true,
  }

  file {"${certificate_dir}/private_keys/${title}_combined.pem":
    ensure  => $ensure,
    content => $ssl_key,
  }

  file {"${certificate_dir}/certs/ca.pem":
    ensure  => $ensure,
    content => $ssl_cacert,
  }

}
