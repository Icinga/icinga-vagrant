require 'spec_helper'

describe 'prometheus::redis_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.11.2',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        it { is_expected.to compile.with_all_deps }
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/redis_exporter').with('target' => '/opt/redis_exporter-0.11.2.linux-amd64/redis_exporter') }
          it { is_expected.to contain_file('/opt/redis_exporter-0.11.2.linux-amd64') }
          it { is_expected.to contain_archive('/tmp/redis_exporter-0.11.2.tar.gz') }
        end
        describe 'required resources' do
          it { is_expected.to contain_group('redis-exporter') }
          it { is_expected.to contain_prometheus__daemon('redis_exporter') }
          it { is_expected.to contain_service('redis_exporter') }
          it { is_expected.to contain_user('redis-exporter') }
        end
      end
    end
  end
end
