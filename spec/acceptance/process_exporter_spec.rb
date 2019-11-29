require 'spec_helper_acceptance'

describe 'prometheus process_exporter' do
  it 'process_exporter works idempotently with no errors' do
    pp = 'include prometheus::process_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('process-exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe port(9256) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'process_exporter update from 0.1.0 to 0.5.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::process_exporter': version => '0.1.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('process-exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9256) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::process_exporter': version => '0.5.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('process-exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9256) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
