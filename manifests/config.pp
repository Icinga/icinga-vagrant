# == Class: kibana5::config
#
# Optionally installs a Kibana5 configuration file. If no configuration is
# supplied, leaves the original Kibana5 config file in place from the package.
#
# === Parameters
#
# See Kibana5 class for details.
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class kibana5::config (
  $config     = $kibana5::config,
  $config_dir = $kibana5::config_dir,
) inherits kibana5 {

  if $config {
    file { 'kibana-config-file':
      ensure    => file,
      path      => "${config_dir}/kibana.yml",
      owner     => 'kibana',
      group     => 'kibana',
      mode      => '0755',
      content   => template('kibana5/kibana.yml.erb'),
      show_diff => false,
    }
  }
}
