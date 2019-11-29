require 'spec_helper'

describe 'prometheus::beanstalkd_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '1.0.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to contain_archive('/tmp/beanstalkd_exporter-1.0.0.tar.gz') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_group('beanstalkd-exporter') }
          it { is_expected.to contain_user('beanstalkd-exporter') }
          it { is_expected.to contain_prometheus__daemon('beanstalkd_exporter') }
          it { is_expected.to contain_service('beanstalkd_exporter') }
        end
        describe 'compile manifest' do
          it { is_expected.to compile.with_all_deps }
        end

        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/beanstalkd_exporter').with('target' => '/opt/beanstalkd_exporter-1.0.0.linux-amd64/beanstalkd_exporter') }
        end
      end
    end
  end
end
