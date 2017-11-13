class profiles::icinga2::config (
  $config_type = 'standalone'
) {

  # TODO: Finish this based on different config provisioning, a bit harder to unroll
  $conf_base_dir = "objects.d"

  if ($config_role == 'standalone') {

  } else if ($config_role == 'master') {
    $conf_base_dir = "zones.d"
  } else if ($config_role == 'satellite') {
    $conf_base_dir = "objects.d"
  } else {
    # throw error
  }


}
