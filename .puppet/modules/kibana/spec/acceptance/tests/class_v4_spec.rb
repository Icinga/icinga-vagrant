require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/class_shared_examples.rb'

describe 'kibana class v4' do
  let(:plugin)         { 'marvel' }
  let(:plugin_version) { '2.4.1' }
  let(:port)           { 5602 }
  let(:version)        { fact('osfamily') == 'RedHat' ? '4.6.4-1' : '4.6.4' }

  let(:manifest) do
    <<-MANIFEST
        class { 'kibana':
          ensure => '#{version}',
          config => {
            'server.host' => '0.0.0.0',
            'server.port' => #{port},
          },
          repo_version => '4.6',
        }

        kibana_plugin { '#{plugin}':
          ensure       => 'present',
          version      => '#{plugin_version}',
          organization => 'elasticsearch'
        }
      MANIFEST
  end

  include_examples 'class manifests',
                   '/opt/kibana/installedPlugins/marvel/package.json',
                   '2.4.4'
end
