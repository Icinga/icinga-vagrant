require 'spec_helper_acceptance'

describe 'prometheus pushgateway' do
  it 'pushgateway works idempotently with no errors' do
    pp = 'include prometheus::pushgateway'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('pushgateway') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe port(9091) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'pushgateway update from 0.4.0 to 0.8.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::pushgateway': version => '0.4.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('pushgateway') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9091) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::pushgateway': version => '0.8.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('pushgateway') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9091) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
