require 'spec_helper'

describe 'influxdb::server', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:params) {{ :influxd_opts => 'OPTIONS' }}
      let(:facts) do
        facts
      end
      it { is_expected.to contain_file('/etc/default/influxdb') }
      it { is_expected.to contain_file('/etc/default/influxdb').with_content(/INFLUXD_OPTS="OPTIONS"/) }
      it { is_expected.to contain_file('/etc/default/influxdb').with_content(/STDERR=\/var\/log\/influxdb\/influxd\.log/) }
    end
  end
end
