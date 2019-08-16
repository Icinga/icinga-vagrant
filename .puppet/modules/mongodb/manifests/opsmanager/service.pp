# @api private
class mongodb::opsmanager::service {
  #assert_private("You are calling a private class mongodb::opsmanager::service.")
  $service_ensure   = $mongodb::opsmanager::ensure
  $service_manage   = $mongodb::opsmanager::service_manage
  $service_enable   = $mongodb::opsmanager::service_enable
  $service_name     = $mongodb::opsmanager::service_name
  $service_provider = $mongodb::opsmanager::service_provider
  $service_status   = $mongodb::opsmanager::service_status

  if $service_manage {
    service { $service_name:
      ensure   => $service_ensure,
      enable   => $service_enable,
      provider => $service_provider,
      status   => $service_status,
    }
  }
}
