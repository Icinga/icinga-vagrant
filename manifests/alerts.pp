# Define: prometheus::alerts
#
# This module manages prometheus alert files for prometheus
#
#  [*alerts*]
#  Array (< prometheus 2.0.0) or Hash (>= prometheus 2.0.0) of alerts (see README).
#
#  [*location*]
#  Where to create the alert file for prometheus
#
define prometheus::alerts (
  Variant[Array,Hash] $alerts,
  String $location = "${prometheus::config_dir}/rules",
  String $version  = $prometheus::version,
  String $user     = $prometheus::user,
  String $group    = $prometheus::group,
  String $bin_dir  = $prometheus::bin_dir,
) {
  if ( versioncmp($version, '2.0.0') < 0 ){
    file { "${location}/${name}.rules":
      ensure       => 'file',
      owner        => 'root',
      group        => $group,
      notify       => Class['prometheus::service_reload'],
      content      => epp("${module_name}/alerts.epp", {'alerts' => $alerts}),
      validate_cmd => "${bin_dir}/promtool check-rules %",
      require      => Class['prometheus::install'],
      before       => Class['prometheus::config'],
    }
  }
  else {
    file { "${location}/${name}.rules":
      ensure       => 'file',
      owner        => 'root',
      group        => $group,
      notify       => Class['prometheus::service_reload'],
      content      => $alerts.to_yaml,
      validate_cmd => "${bin_dir}/promtool check rules %",
      require      => Class['prometheus::install'],
      before       => Class['prometheus::config'],
    }
  }
}
