require 'spec_helper_acceptance'

describe 'prometheus snmp exporter' do
  it 'snmp_exporter works idempotently with no errors' do
    pp = 'include prometheus::snmp_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('snmp_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  # the class installs an the snmp_exporter that listens on port 9104
  describe port(9116) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'snmp_exporter update from 0.7.0 to 0.15.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::snmp_exporter': version => '0.7.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('snmp_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9116) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::snmp_exporter': version => '0.15.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('snmp_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9116) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
