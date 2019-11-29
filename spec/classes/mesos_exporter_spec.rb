require 'spec_helper'

describe 'prometheus::mesos_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let :params do
          {
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'compile manifest' do
          it { is_expected.to compile.with_all_deps }
        end

        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/mesos_exporter').with('target' => '/opt/mesos_exporter-1.1.2.linux-amd64/mesos_exporter') }
        end
      end
    end
  end
end
