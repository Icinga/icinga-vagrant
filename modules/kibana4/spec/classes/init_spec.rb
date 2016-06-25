require 'spec_helper'

describe 'kibana4' do

  context 'with defaults for all parameters' do
    let :facts do
      {
         :osfamily => 'RedHat'
      }
    end
    it { is_expected.to contain_class('kibana4') }
  end

  context 'installs via package' do
    let :facts do
      {
         :osfamily => 'RedHat'
      }
    end
    let :params do
      {
        :version             => 'latest',
        :service_ensure      => true,
        :service_enable      => true,
        :config		     => {
          'server.port'           => 5601,
          'server.host'           => '0.0.0.0',
          'elasticsearch.url'     => 'http://localhost:9200'
        }
      }
    end
    it { is_expected.to contain_package('kibana4') }
    it { is_expected.to contain_file('kibana-config-file').with_path('/opt/kibana/config/kibana.yml') }
    it { is_expected.to contain_service('kibana4').with_ensure('true').with_enable('true') }
  end

end
