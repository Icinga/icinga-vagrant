# == Class grafana::config
#
# This class is called from grafana
#
class grafana::config {
  case $::grafana::install_method {
    'docker': {
      if $::grafana::container_cfg {
        $cfg = $::grafana::cfg

        file {  $::grafana::cfg_location:
          ensure  => present,
          content => template('grafana/config.ini.erb'),
        }
      }
    }
    'package','repo': {
      $cfg = $::grafana::cfg

      file {  $::grafana::cfg_location:
        ensure  => present,
        content => template('grafana/config.ini.erb'),
      }
    }
    'archive': {
      $cfg = $::grafana::cfg

      file { "${::grafana::install_dir}/conf/custom.ini":
        ensure  => present,
        content => template('grafana/config.ini.erb'),
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }

  if $::grafana::ldap_cfg {
    $ldap_cfg = $::grafana::ldap_cfg
    file { '/etc/grafana/ldap.toml':
      ensure  => present,
      content => inline_template("<%= require 'toml'; TOML::Generator.new(@ldap_cfg).body %>\n"),
    }
  }
}
