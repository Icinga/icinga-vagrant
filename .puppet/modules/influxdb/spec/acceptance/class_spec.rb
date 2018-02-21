require 'spec_helper_acceptance'

describe 'influxdb class', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'default parameters' do
    pp = <<-EOS

    class { 'influxdb':
      manage_repos => true,
    }

    EOS

    it 'works with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      # wait because influxdb takes few seconds to start
      shell('/bin/sleep 10')
    end

    describe package('influxdb') do
      it { is_expected.to be_installed }
    end

    describe port('8086') do
      it { is_expected.to be_listening }
    end

    describe process('influxd') do
      its(:user) { is_expected.to eq 'influxdb' }
    end

    describe command('/usr/bin/test_facter.sh influxdb_version') do
      its(:stdout) { is_expected.to eq "1.2.0\n" }
    end

    describe port('8089') do
      it { is_expected.not_to be_listening }
    end
  end
end
