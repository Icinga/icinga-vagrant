require 'spec_helper'

describe 'influxdb' do

   on_supported_os.each do |os, facts|
     context "on #{os}" do
       let(:facts) do
         facts
      end
       it { should contain_class('influxdb') }
       it { is_expected.to compile.with_all_deps }
     end
   end
end
