class profile::nginx {

    # This profile can be used by many nodes and thus the node configuration is
    # in the hiera file for the respective node!
    class { '::nginx':
        manage_repo => true,
        package_source => 'nginx-stable'
    }->
    class { '::collectd::plugin::nginx':
        url => 'http://localhost:8433/nginx-status',
    }

    # Icinga: install check into PluginContribDir
    # (PluginContribDir could be a fact "icinga2 variable get PluginContribDir",
    # but for that to work, puppet would probably have to run twice…)
    file { '/usr/lib/nagios/plugins/check_nginx_status.pl':
        ensure  => file,
        mode    => '+x',
        source => [
            'puppet:///modules/1024/icinga/plugins/check_nginx_status.pl',
        ],
        require => Package['monitoring-plugins-standard'],
    }

}
