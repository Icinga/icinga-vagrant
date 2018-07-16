class profiles::elastic::kibana (
  $kibana_revision = '6.3.1-1',
  $kibana_port = 5601,
  $kibana_host = '127.0.0.1',
  $kibana_default_app_id = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'
) {
  # requires profiles::elastic::elasticsearch to setup the repository
  class { 'kibana':
    oss     => true,
    ensure  => $kibana_revision,
    config  => {
      'server.port'                  => $kibana_port,
      'server.host'                  => $kibana_host,
      'kibana.index'                 => '.kibana',
      'kibana.defaultAppId'          => $kibana_default_app_id,
      'logging.silent'               => false,
      'logging.quiet'                => false,
      'logging.verbose'              => false,
      'logging.events'               => "{ log: ['info', 'warning', 'error', 'fatal'], response: '*', error: '*' }",
      'elasticsearch.requestTimeout' => 500000,
    },
  }

}
