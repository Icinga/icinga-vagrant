require 'spec_helper'

describe 'prometheus::blackbox_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.6.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url',
            modules: {
              'http_2xx' => {
                'prober' => 'http'
              }
            }
          }
        end

        describe 'with all defaults' do
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/bin/blackbox_exporter').with('target' => '/opt/blackbox_exporter-0.6.0.linux-amd64/blackbox_exporter') }
          it { is_expected.to contain_prometheus__daemon('blackbox_exporter') }
          it { is_expected.to contain_user('blackbox-exporter') }
          it { is_expected.to contain_group('blackbox-exporter') }
          it { is_expected.to contain_service('blackbox_exporter') }
          it { is_expected.to contain_archive('/tmp/blackbox_exporter-0.6.0.tar.gz') }
          it { is_expected.to contain_file('/opt/blackbox_exporter-0.6.0.linux-amd64/blackbox_exporter') }
          it {
            is_expected.to contain_file('/etc/blackbox-exporter.yaml')
            verify_contents(catalogue, '/etc/blackbox-exporter.yaml', ['---', 'modules:', '  http_2xx:', '    prober: http'])
          }
        end
      end
    end
  end
end
