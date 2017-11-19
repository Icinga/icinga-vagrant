class profiles::base::apache {
  class {'apache':
    # don't purge php, icingaweb2, etc configs
    purge_configs => false,
    default_vhost => false,
  }
}
