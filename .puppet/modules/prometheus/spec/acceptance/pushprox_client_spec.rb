require 'spec_helper_acceptance'

describe 'prometheus pushprox_client' do
  it 'pushprox_client works idempotently with no errors' do
    pp = <<-EOS
      class { 'prometheus::pushprox_proxy': }
      class { 'prometheus::pushprox_client':
        proxy_url => 'http://localhost:8080',
      }
    EOS
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end
  describe service('pushprox_proxy') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe service('pushprox_client') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  # the class installs an the pushprox_proxy that listens on port 8080
  describe port(8080) do
    it { is_expected.to be_listening.with('tcp6') }
  end
  # the class installs an the pushprox_client that listens on port 9369
  describe port(9369) do
    it { is_expected.to be_listening.with('tcp6') }
  end
end
