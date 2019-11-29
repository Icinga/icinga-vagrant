class profiles::prometheus::node_exporter (
  $version = lookup('prometheus::node_exporter::version')
) {
  class { 'prometheus::node_exporter':
    version            => $version,
    collectors_disable => ['loadavg', 'mdadm'],
    extra_options      => '--collector.ntp.server ntp1.orange.intra',
  }
}
