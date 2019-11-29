require 'spec_helper_acceptance'

describe 'prometheus blackbox exporter' do
  it 'blackbox_exporter works idempotently with no errors' do
    pp = 'include prometheus::blackbox_exporter'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('blackbox_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe port(9115) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'blackbox_exporter update from 0.7.0 to 0.14.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::blackbox_exporter': version => '0.7.0'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('blackbox_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9115) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::blackbox_exporter': version => '0.14.0'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('blackbox_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9115) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
