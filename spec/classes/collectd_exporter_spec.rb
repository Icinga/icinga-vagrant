require 'spec_helper'

describe 'prometheus::collectd_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to contain_prometheus__daemon('collectd_exporter') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_group('collectd-exporter') }
        it { is_expected.to contain_service('collectd_exporter') }
        it { is_expected.to contain_user('collectd-exporter') }
        it { is_expected.to contain_class('prometheus') }
      end

      context 'with params' do
        let :params do
          {
            install_method: 'url'
          }
        end

        it { is_expected.to contain_archive('/tmp/collectd_exporter-0.4.0.tar.gz') }
      end
    end
  end
end
