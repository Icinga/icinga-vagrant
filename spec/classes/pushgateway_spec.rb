require 'spec_helper'

describe 'prometheus::pushgateway' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.4.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/pushgateway').with('target' => '/opt/pushgateway-0.4.0.linux-amd64/pushgateway') }
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
