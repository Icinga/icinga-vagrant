require 'spec_helper_acceptance'

describe 'prometheus mesos exporter' do
  it 'mesos_exporter works idempotently with no errors' do
    pp = 'include prometheus::mesos_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('mesos_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe 'prometheus mesos exporter version 1.0.0' do
    it 'mesos_exporter installs with version 1.0.0' do
      pp = "class {'prometheus::mesos_exporter': version => '1.0.0' }"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe service('mesos_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end

  describe 'prometheus mesos exporter version 1.1.2' do
    it 'mesos_exporter installs with version 1.1.2' do
      pp = "class {'prometheus::mesos_exporter': version => '1.1.2' }"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe service('mesos_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
