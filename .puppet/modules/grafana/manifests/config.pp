# == Class grafana::config
#
# This class is called from grafana
#
class grafana::config {
  case $::grafana::install_method {
    'docker': {
      if $::grafana::container_cfg {
        $cfg = $::grafana::cfg
        $myprovision = false

        file {  $::grafana::cfg_location:
          ensure  => file,
          content => template('grafana/config.ini.erb'),
          owner   => 'grafana',
          group   => 'grafana',
        }
      }
    }
    'package','repo': {
      $cfg = $::grafana::cfg
      $myprovision = true

      file {  $::grafana::cfg_location:
        ensure  => file,
        content => template('grafana/config.ini.erb'),
        owner   => 'grafana',
        group   => 'grafana',
      }

      $sysconfig = $::grafana::sysconfig
      $sysconfig_location = $::grafana::sysconfig_location

      if $sysconfig_location and $sysconfig {
        $changes = $sysconfig.map |$key, $value| { "set ${key} ${value}" }

        augeas{'sysconfig/grafana-server':
          context => "/files${$sysconfig_location}",
          changes => $changes,
        }
      }

      file { "${::grafana::data_dir}/plugins":
        ensure => directory,
        owner  => 'grafana',
        group  => 'grafana',
        mode   => '0750',
      }
    }
    'archive': {
      $cfg = $::grafana::cfg
      $myprovision = true

      file { "${::grafana::install_dir}/conf/custom.ini":
        ensure  => file,
        content => template('grafana/config.ini.erb'),
        owner   => 'grafana',
        group   => 'grafana',
      }

      file { [$::grafana::data_dir, "${::grafana::data_dir}/plugins"]:
        ensure => directory,
        owner  => 'grafana',
        group  => 'grafana',
        mode   => '0750',
      }
    }
    default: {
      fail("Installation method ${::grafana::install_method} not supported")
    }
  }

  if $::grafana::ldap_cfg {
    $ldap_cfg = $::grafana::ldap_cfg
    file { '/etc/grafana/ldap.toml':
      ensure  => file,
      content => inline_template("<%= require 'toml'; TOML::Generator.new(@ldap_cfg).body %>\n"),
      owner   => 'grafana',
      group   => 'grafana',
    }
  }

  # If grafana version is > 5.0.0, and the install method is package,
  # repo, or archive, then use the provisioning feature. Dashboards
  # and datasources are placed in
  # /etc/grafana/provisioning/[dashboards|datasources] by default.
  # --dashboards--
  if ((versioncmp($grafana::version, '5.0.0') >= 0) and ($myprovision)) {
    $pdashboards = $grafana::provisioning_dashboards
    if (length($pdashboards) >= 1 ) {
      $dashboardpaths = flatten(grafana::deep_find_and_remove('options', $pdashboards))
      # template uses:
      #   - pdashboards
      file { $grafana::provisioning_dashboards_file:
        ensure  => file,
        owner   => 'grafana',
        group   => 'grafana',
        mode    => '0640',
        content => epp('grafana/pdashboards.yaml.epp'),
        notify  => Service[$grafana::service_name],
      }
      # Loop over all providers, extract the paths and create
      # directories for each path of dashboards.
      $dashboardpaths.each | Integer $index, Hash $options | {
        if ('path' in $options) {
          # get sub paths of 'path' and create subdirs if necessary
          $subpaths = grafana::get_sub_paths($options['path'])
          if ($grafana::create_subdirs_provisioning and (length($subpaths) >= 1)) {
            file { $subpaths :
              ensure => directory,
              before => File[$options['path']],
            }
          }

          file { $options['path'] :
            ensure  => directory,
            owner   => 'grafana',
            group   => 'grafana',
            mode    => '0750',
            recurse => true,
            purge   => true,
            source  => $options['puppetsource'],
          }
        }
      }
    }

    # --datasources--
    $pdatasources = $grafana::provisioning_datasources
    if (length($pdatasources) >= 1) {
      # template uses:
      #   - pdatasources
      file { $grafana::provisioning_datasources_file:
        ensure  => file,
        owner   => 'grafana',
        group   => 'grafana',
        mode    => '0640',
        content => epp('grafana/pdatasources.yaml.epp'),
        notify  => Service[$grafana::service_name],
      }
    }

  }
}
