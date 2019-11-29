require 'spec_helper'

describe 'prometheus::nginx_vts_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.6',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to contain_archive('/tmp/nginx-vts-exporter-0.6.tar.gz') }
          it { is_expected.to contain_user('nginx-vts-exporter') }
          it { is_expected.to contain_group('nginx-vts-exporter') }
          it { is_expected.to contain_service('nginx-vts-exporter') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_prometheus__daemon('nginx-vts-exporter') }
        end
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/nginx-vts-exporter').with('target' => '/opt/nginx-vts-exporter-0.6.linux-amd64/nginx-vts-exporter') }
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
