require 'spec_helper_acceptance'

describe 'influxdb class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'default parameters' do

    pp = <<-EOS
    class { 'influxdb::server': }
    EOS

    it 'should work with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # wait because influxdb takes few seconds to start
      shell("/bin/sleep 10")
    end

    describe package('influxdb') do
      it { is_expected.to be_installed }
    end

    describe port('8086') do
      it { should be_listening }
    end

    describe process("influxdb") do
      its(:user) { should eq "influxdb" }
    end

    describe port('8089') do
      it { should_not be_listening }
    end
  end

  context 'change some ports' do

    it 'should change API port to 8089' do
      pp = <<-EOS
      class { 'influxdb::server': api_port => 8089}
      EOS

      apply_manifest(pp, :catch_failures => true)
      shell("/bin/sleep 10")
    end

    describe port('8089') do
      it { should be_listening }
    end
  end

end