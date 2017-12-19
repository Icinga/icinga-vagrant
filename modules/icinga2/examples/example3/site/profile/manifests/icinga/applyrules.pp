class profile::icinga::applyrules {

    # Global apply rules
    # We attempt to export them with the respective services where possible.
    # However, that only works if the service is unique on the infrastructure and would
    # not lead to duplicate resources.
    #
    # All multi-use (apply) services are defined here.
    #
    # We do not use "icinga2::object::service" but files with the "icinga2::config::file" tag. See the
    # example's README on why this is the case.

    file { '/etc/icinga2/conf.d/services/nginx.conf':
        ensure  => file,
        owner   => 'nagios',
        group   => 'nagios',
        tag     => 'icinga2::config::file',
        source => [
            "puppet:///modules/1024/icinga/services/nginx.conf",
        ],
    }

    file { '/etc/icinga2/conf.d/services/postgres.conf':
        ensure  => file,
        owner   => 'nagios',
        group   => 'nagios',
        tag     => 'icinga2::config::file',
        source => [
            "puppet:///modules/1024/icinga/services/postgres.conf",
        ],
    }

    file { '/etc/icinga2/conf.d/services/elasticsearch.conf':
        ensure  => file,
        owner   => 'nagios',
        group   => 'nagios',
        tag     => 'icinga2::config::file',
        source => [
            "puppet:///modules/1024/icinga/services/elasticsearch.conf",
        ],
    }

    # Collect any files exported and tagged elsewhere (can be created inside
    # services or master zone)
    # We need to use a different tag then icinga itself (icinga2::config::file)
    # or the agent will try to collect any resources tagged so on himself.
    File <<| ensure != 'directory' and tag == 'icinga2::config::exported' |>> {
        require => [
            File['icinga2_masterzone'],
            File['icinga2_services'],
        ],
    }
}
