require 'spec_helper_acceptance'

describe 'prometheus haproxy_exporter' do
  it 'haproxy_exporter works idempotently with no errors' do
    pp = 'include prometheus::haproxy_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('haproxy_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe port(9101) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'haproxy_exporter update from 0.7.1 to 0.9.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::haproxy_exporter': version => '0.7.1'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('haproxy_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9101) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::haproxy_exporter': version => '0.9.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('haproxy_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9101) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end

  describe 'haproxy_exporter update from 0.9.0 to 0.10.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::haproxy_exporter': version => '0.9.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('haproxy_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9101) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::haproxy_exporter': version => '0.10.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('haproxy_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9101) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
