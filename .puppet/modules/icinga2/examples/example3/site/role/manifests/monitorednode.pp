class role::monitorednode {
    contain profile::icinga::agent
    contain profile::graylog::collector_sidecar
}
