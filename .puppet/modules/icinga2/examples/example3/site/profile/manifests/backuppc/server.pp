class profile::backuppc::server {
    class { '::backuppc::server': }
    create_resources('backuppc::server::user', hiera('backuppc_users', []))

    # Icinga CheckCommand and Apply Rules
    @@icinga2::object::checkcommand { 'backuppc':
        import      => [
            'plugin-check-command',
        ],
        command     => [
            'sudo', '-u', 'backuppc',
            'PluginContribDir + /check_backuppc',
        ],
        arguments   => {
            '-w' => '$backuppc_wtime$',
            '-c' => '$backuppc_ctime$',
            '-H' => {
                'value' => '$backuppc_desired$',
                'set_if' => '$backuppc_desired$',
            },
            '-x' => {
                'value' => '$backuppc_exclude$',
                'set_if' => '$backuppc_exclude$',
            },
            '-V' => {
                'set_if' => '$backuppc_version$'
            },
            '-a' => {
                'set_if' => '$backuppc_archiveonly$',
            },
            '-b' => {
                'set_if' => '$backuppc_backuponly$',
            },
            '-s' => {
                'set_if' => '$backuppc_statusonly$',
            },
        },
        vars        => {
            'backuppc_wtime' => '2',
            'backuppc_ctime' => '4',
        },
        target      => '/etc/icinga2/zones.d/global-templates/backuppc-command.conf',
    }

    @@file { '/etc/icinga2/conf.d/services/backuppc.conf':
        ensure  => file,
        owner   => 'nagios',
        group   => 'nagios',
        tag     => 'icinga2::config::exported',
        source => [
            "puppet:///modules/1024/icinga/services/backuppc.conf",
        ],
    }
}
