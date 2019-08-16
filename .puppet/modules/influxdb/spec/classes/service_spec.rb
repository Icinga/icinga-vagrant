require 'spec_helper'

describe 'influxdb::service' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        let(:pre_condition) do
          <<-EOS
 include influxdb
          EOS
        end

        it do
          is_expected.to contain_service('influxdb').with(ensure: 'running',
                                                          enable: true,
                                                          hasrestart: true,
                                                          hasstatus: true,
                                                          require: 'Package[influxdb]')
        end

        it { is_expected.to contain_class('influxdb::service') }
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
