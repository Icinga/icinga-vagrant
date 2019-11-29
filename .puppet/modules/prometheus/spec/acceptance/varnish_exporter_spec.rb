require 'spec_helper_acceptance'

describe 'prometheus varnish exporter' do
  it 'varnish_exporter works idempotently with no errors' do
    pp = 'include prometheus::varnish_exporter'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('prometheus_varnish_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe port(9131) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'varnish_exporter update from 1.4 to 1.5' do
    it 'is idempotent' do
      pp = "class{'prometheus::varnish_exporter': version => '1.4'}"
      apply_manifest(pp, catch_failures: true)
    end

    describe service('prometheus_varnish_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9131) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::varnish_exporter': version => '1.5'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('prometheus_varnish_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9131) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
