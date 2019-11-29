require 'spec_helper'

describe 'prometheus::process_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_user('process-exporter') }
        it { is_expected.to contain_group('process-exporter') }
        it { is_expected.to contain_prometheus__daemon('process-exporter').with(options: '-config.path=/etc/process-exporter.yaml ') }
        it { is_expected.to contain_service('process-exporter') }
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.2.4',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/process-exporter-0.2.4.tar.gz') }
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/process-exporter').with('target' => '/opt/process-exporter-0.2.4.linux-amd64/process-exporter') }
        end
      end
    end
  end
end
