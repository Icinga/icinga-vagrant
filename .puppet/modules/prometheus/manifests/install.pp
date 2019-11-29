# Class prometheus::server::install
# Install prometheus via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::install {

  assert_private()

  if $prometheus::server::localstorage {
    file { $prometheus::server::localstorage:
      ensure => 'directory',
      owner  => $prometheus::server::user,
      group  => $prometheus::server::group,
      mode   => '0755',
    }
  }
  case $prometheus::server::install_method {
    'url': {
      archive { "/tmp/prometheus-${prometheus::server::version}.${prometheus::server::download_extension}":
        ensure          => present,
        extract         => true,
        extract_path    => '/opt',
        source          => $prometheus::server::real_download_url,
        checksum_verify => false,
        creates         => "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/prometheus",
        cleanup         => true,
        extract_command => $prometheus::extract_command,
      }
      -> file {
        "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/prometheus":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${prometheus::server::bin_dir}/prometheus":
          ensure => link,
          notify => $prometheus::server::notify_service,
          target => "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/prometheus";
        "${prometheus::server::bin_dir}/promtool":
          ensure => link,
          target => "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/promtool";
        $prometheus::server::shared_dir:
          ensure => directory,
          owner  => $prometheus::server::user,
          group  => $prometheus::server::group,
          mode   => '0755';
        "${prometheus::server::shared_dir}/consoles":
          ensure => link,
          notify => $prometheus::server::notify_service,
          target => "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/consoles";
        "${prometheus::server::shared_dir}/console_libraries":
          ensure => link,
          notify => $prometheus::server::notify_service,
          target => "/opt/prometheus-${prometheus::server::version}.${prometheus::server::os}-${prometheus::server::real_arch}/console_libraries";
      }
    }
    'package': {
      package { $prometheus::server::package_name:
        ensure => $prometheus::server::package_ensure,
        notify => $prometheus::server::notify_service,
      }
      if $prometheus::server::manage_user {
        User[$prometheus::server::user] -> Package[$prometheus::server::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${prometheus::server::install_method} is invalid")
    }
  }
  if $prometheus::server::manage_user {
    ensure_resource('user', [ $prometheus::server::user ], {
      ensure => 'present',
      system => true,
      groups => $prometheus::server::extra_groups,
      shell  => $prometheus::server::usershell,
    })

    if $prometheus::server::manage_group {
      Group[$prometheus::server::group] -> User[$prometheus::server::user]
    }
  }
  if $prometheus::server::manage_group {
    ensure_resource('group', [ $prometheus::server::group ],{
      ensure => 'present',
      system => true,
    })
  }
  file { $prometheus::server::config_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $prometheus::server::group,
    purge   => $prometheus::server::purge_config_dir,
    recurse => $prometheus::server::purge_config_dir,
  }
}
