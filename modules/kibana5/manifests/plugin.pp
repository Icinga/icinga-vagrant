# == Definition: kibana5::plugin
#
# Manages a Kibana5 plugin
#
# === Parameters
#
# ...
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
define kibana5::plugin (
  $ensure = 'present',
  $url    = undef,
) {

  include ::kibana5
  include ::kibana5::service
  $_install_dir = $::kibana5::install_dir
  $_bin_dir     = $::kibana5::bin_dir
  $_plugin_dir  = "${_install_dir}/plugins"

  case $ensure {
    'present': {
      if !$url {
        exec { "install_kibana_plugin_${name}":
          command => "${_bin_dir}/kibana-plugin install ${name}",
          path    => "${_bin_dir}:/sbin:/bin:/usr/sbin:/usr/bin",
          creates => "${_plugin_dir}/${name}",
          notify  => Class['kibana5::service'];
        }
      } else {
        exec { "install_kibana_plugin_${name}":
          command => "${_bin_dir}/kibana-plugin install ${name} -u ${url}",
          path    => "${_bin_dir}:/sbin:/bin:/usr/sbin:/usr/bin",
          unless  => "test -d ${_plugin_dir}/${name}",
          notify  => Class['kibana5::service'];
        }
      }
    }

    'absent': {
        exec { "remove_kibana_plugin_${name}":
          command => "rm -rf ${_plugin_dir}/${name}",
          path    => '/sbin:/bin:/usr/sbin:/usr/bin',
          unless  => "test ! -d ${_plugin_dir}/${name}",
          notify  => Class['kibana5::service'];
        }
    }
    default: {
      fail('`ensure` should be either `present` or `absent`')
    }
  }
}
