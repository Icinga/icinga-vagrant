require 'spec_helper_acceptance'

describe 'prometheus statsd exporter' do
  it 'statsd_exporter works idempotently with no errors' do
    pp = 'include prometheus::statsd_exporter'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end
  describe service('statsd_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe port(9102) do
    it { is_expected.to be_listening.with('tcp6') }
  end
  describe port(9125) do
    it { is_expected.to be_listening.with('udp6') }
  end
  describe 'prometheus statsd exporter version 0.8.0' do
    it ' statsd_exporter installs with version 0.8.0' do
      pp = "class {'prometheus::statsd_exporter': version => '0.8.0' }"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('statsd_exporter') do
      its(:args) { is_expected.to match %r{\ --statsd.mapping-config} }
    end
    describe service('statsd_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
    describe port(9102) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    describe port(9125) do
      it { is_expected.to be_listening.with('udp6') }
    end
  end

  describe 'prometheus statsd exporter version 0.12.1' do
    it ' statsd_exporter installs with version 0.12.1' do
      pp = "class {'prometheus::statsd_exporter': version => '0.12.1' }"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('statsd_exporter') do
      its(:args) { is_expected.to match %r{\ --statsd.mapping-config} }
    end
    describe service('statsd_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
    describe port(9102) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    describe port(9125) do
      it { is_expected.to be_listening.with('udp6') }
    end
  end
end
