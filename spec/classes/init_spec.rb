require 'spec_helper'

describe 'influxdb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        it { is_expected.to contain_anchor('influxdb::start') }
        it { is_expected.to contain_class('influxdb::params') }
        it { is_expected.to contain_class('influxdb') }
        it { is_expected.to contain_class('influxdb::install') }
        it { is_expected.to contain_class('influxdb::config') }
        it { is_expected.to contain_class('influxdb::service') }
        it { is_expected.to contain_anchor('influxdb::end') }

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
