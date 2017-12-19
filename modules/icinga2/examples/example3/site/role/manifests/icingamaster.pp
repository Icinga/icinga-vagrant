class role::icingamaster {
    contain profile::hosts
    contain profile::letsencrypt
    contain profile::nginx
    contain profile::php
    contain profile::mysqlserver
    contain profile::icinga::server
    contain profile::graylog::collector_sidecar
}
