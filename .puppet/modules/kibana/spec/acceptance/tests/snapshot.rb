require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples'

describe 'kibana snapshots' do
  let(:port) { 5602 }
  let(:version) { RSpec.configuration.snapshot_version }
  let(:manifest) do
    <<-MANIFEST
      class { 'kibana':
        config => {
          'server.host' => '0.0.0.0',
          'server.port' => #{port},
        },
        manage_repo => false,
        oss => #{RSpec.configuration.oss},
        package_source => '/tmp/kibana-snapshot.#{RSpec.configuration.pkg_ext}',
      }
    MANIFEST
  end

  include_examples 'basic acceptance'
end
