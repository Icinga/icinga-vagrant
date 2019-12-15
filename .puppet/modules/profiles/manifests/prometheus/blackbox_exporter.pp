class profiles::prometheus::blackbox_exporter (
  $version = lookup('prometheus::blackbox_exporter::version')
) {
  class { 'prometheus::blackbox_exporter':
    modules => {
      'http_2xx' => {
        'prober' => 'http',
        'timeout' => '30s',
        'http' => {
          'preferred_ip_protocol' => 'ip4',
          'ip_protocol_fallback' => false, 
          'fail_if_ssl' => false
        }
      }
    }
  }
}
