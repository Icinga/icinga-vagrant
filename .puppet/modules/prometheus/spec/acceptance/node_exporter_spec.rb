require 'spec_helper_acceptance'

describe 'prometheus node_exporter' do
  it 'node_exporter works idempotently with no errors' do
    pp = 'include prometheus::node_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('node_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe port(9100) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'node_exporter update from 0.15.2 to 0.16.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::node_exporter': version => '0.15.2'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('node_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9100) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::node_exporter': version => '0.16.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('node_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9100) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
