# == Define: icingaweb2::module::puppetdb
#
# Install and configure the puppetdb module.  It is possible to let the module
# to configure the ssl certificates to connect to one or more PuppetDBs.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*git_repository*]
#   Set a git repository URL. Defaults to github.
#
# [*git_revision*]
#   Set either a branch or a tag name, eg. `master` or `v1.3.2`.
#
# [*ssl*]
#   How to set up ssl certificates. To copy certificates from the local puppet installation, use `puppet`. Defaults to
#   `none`
#
# [*host*]
#   Hostname of the server where PuppetDB is running. The `ssl` parameter needs to be set to `puppet`.
#
# [*certificates*]
#   Hash with icingaweb2::module::puppetdb::certificate resources.
#
class icingaweb2::module::puppetdb(
  Enum['absent', 'present'] $ensure         = 'present',
  String                    $git_repository = 'https://github.com/Icinga/icingaweb2-module-puppetdb.git',
  Optional[String]          $git_revision   = undef,
  Enum['none', 'puppet']    $ssl            = 'none',
  Optional[String]          $host           = undef,
  Hash                      $certificates   = {},
){
  $conf_dir   = "${::icingaweb2::params::conf_dir}/modules/puppetdb"
  $ssl_dir    = "${conf_dir}/ssl"
  $conf_user  = $::icingaweb2::conf_user
  $conf_group = $::icingaweb2::params::conf_group

  file { $ssl_dir:
    ensure  => 'directory',
    group   => $conf_group,
    owner   => $conf_user,
    mode    => '2740',
    purge   => true,
    force   => true,
    recurse => true,
  }

  case $ssl {
    'puppet': {

      $puppetdb_ssldir = "${ssl_dir}/${host}"

      file { [$puppetdb_ssldir, "${puppetdb_ssldir}/private_keys", "${puppetdb_ssldir}/certs"]:
        ensure  => 'directory',
        group   => $conf_group,
        owner   => $conf_user,
        mode    => '2740',
        purge   => true,
        force   => true,
        recurse => true,
      }

      file { "${puppetdb_ssldir}/certs/ca.pem":
        ensure => 'present',
        group  => $conf_group,
        owner  => $conf_user,
        mode   => '0640',
        source => "${::settings::ssldir}/certs/ca.pem",
      }

      $combinedkey_path = "${puppetdb_ssldir}/private_keys/${::fqdn}_combined.pem"

      notice("${::settings::ssldir}")

      concat { $combinedkey_path:
        ensure         => present,
        warn           => false,
        owner          => $conf_user,
        group          => $conf_group,
        mode           => '0640',
        ensure_newline => true,
      }

      concat::fragment { 'private_key':
        target => $combinedkey_path,
        source => "${::settings::ssldir}/private_keys/${::fqdn}.pem",
        order  => 1,
      }

      concat::fragment { 'public_key':
        target => $combinedkey_path,
        source => "${::settings::ssldir}/certs/${::fqdn}.pem",
        order  => 2,
      }

    } # puppet
    'none': { }
    default: { }
  } # case ssl

  create_resources('icingaweb2::module::puppetdb::certificate',$certificates)

  icingaweb2::module {'puppetdb':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
  }
}
