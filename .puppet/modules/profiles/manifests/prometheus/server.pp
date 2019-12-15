class profiles::prometheus::server (
  $version = lookup('prometheus::server::version')
) {
  class { 'prometheus::server':
    version => $version,
    alerts         => {
      'groups' => [
        {
          'name'  => 'alert.rules',
          'rules' => [
            {
              'alert'       => 'InstanceDown',
              'expr'        => 'up == 0',
              'for'         => '5m',
              'labels'      => {
                'severity' => 'page',
              },
              'annotations' => {
                'summary'     => 'Instance {{ $labels.instance }} down',
                'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
              }
            },
          ],
        },
      ],
    },
    # TODO: Move this into the box environment
    scrape_configs => [
      {
        'job_name'        => 'prometheus',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ 'localhost:9090' ],
            'labels'  => {
              'alias' => 'Prometheus',
            }
          }
        ],
      },
      {
        'job_name'        => 'prometheus-node-exporter',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ 'localhost:9100' ],
            'labels'  => {
              'alias' => 'Prometheus Node Exporter',
            }
          }
        ],
      },
      {
        'job_name'        => 'everyonecancontribute-node-exporter',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ '78.47.112.51:9100' ],
            'labels'  => {
              'alias' => 'Everyonecancontribute Node Exporter',
            }
          }
        ],
      },
      {
        'job_name'        => 'everyonecancontribute-docker',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ '78.47.112.51:9323' ],
            'labels'  => {
              'alias' => 'Everyonecancontribute Docker',
            }
          }
        ],
      },
      {
        'job_name'        => 'everyonecancontribute-tls',
        'metrics_path'    => '/probe',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ 'https://everyonecancontribute.com', 'https://gitlab.com' ],
            'labels'  => {
              'alias' => 'Everyonecancontribute TLS',
            }
          }
        ],
        'relabel_configs' => [
          {
            'source_labels' => '[__address__]',
            'target_label'  => '__param_target',
          },
          {
            'source_labels' => '[__param_target]',
            'target_label'  => 'instance',
          },
          {
            'target_label' => '__address__',
            'replacement'  => '78.47.112.51:9219',
          },
        ],
      },
      {
        'job_name'        => 'blackbox',
        'metrics_path'    => '/probe',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ 'https://everyonecancontribute.com', 'https://gitlab.com' ],
            'labels'  => {
              'alias' => 'TLS Certificate Monitoring',
            }
          }
        ],
        'relabel_configs' => [
          {
            'source_labels' => '[__address__]',
            'target_label'  => '__param_target',
          },
          {
            'source_labels' => '[__param_target]',
            'target_label'  => 'instance',
          },
          {
            'target_label' => '__address__',
            'replacement'  => '127.0.0.1:9115',
          },
        ],
      },

    ],

  }
}
