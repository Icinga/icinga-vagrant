require 'spec_helper_acceptance'

describe 'prometheus exporter' do
  it 'graphite_exporter works idempotently with no errors' do
    pp = 'include prometheus::graphite_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('graphite_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  # the class installs an exporter that listens on three ports
  # it should not install the prometheus server (port 9090)
  describe port(9108) do
    it { is_expected.to be_listening.with('tcp6') }
  end
  describe port(9109) do
    it { is_expected.to be_listening.with('tcp6') }
  end
  describe port(9109) do
    it { is_expected.to be_listening.with('udp6') }
  end
  describe port(9090) do
    it { is_expected.not_to be_listening.with('tcp6') }
  end
end
