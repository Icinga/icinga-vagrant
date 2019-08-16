require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'when influxdb present' do
        it 'expect Facter[:influxdb_version].value == "1.2.0"' do
          influxdb_output = '1.2.0'

          # we stub/mock the call to Facter::Util::Resolution.exec with our fake (unit test) data
          Facter::Util::Resolution.stubs(:which).with('influx').returns(true)

          # we stub/mock the call to Facter::Util::Resolution.exec with our fake (unit test) data
          Facter::Util::Resolution.stubs(:exec).with('influx --version').returns(influxdb_output)

          # now we assert what we expect for our custom fact.
          expect(Facter[:influxdb_version].value).to eq '1.2.0'
        end
      end

      describe 'when influxdb not present' do
        it 'expect Facter[:influxdb_version].value == nil' do
          expect(Facter[:influxdb_version].value).to eq nil
        end
      end
    end
  end
end
