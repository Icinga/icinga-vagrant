require 'spec_helper_acceptance'

describe 'prometheus redis exporter' do
  context 'default version' do
    it 'redis_exporter works idempotently with no errors' do
      pp = 'include prometheus::redis_exporter'
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('redis_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
    # the class installs an the redis_exporter that listens on port 9121
    describe port(9121) do
      it { is_expected.to be_listening.with('tcp6') }
    end

    it 'is version v1.3.4' do
      shell('curl -s http://127.0.0.1:9121/metrics') do |r|
        redis_exporter_build_info = r.stdout.split(%r{\n}).find { |line| line =~ %r{^redis_exporter_build_info} }
        expect(redis_exporter_build_info).to match(%r{,version="v1\.3\.4"})
      end
    end
  end
  context 'with version 0.11.2 (default version in module version < 8.0.0)' do
    it 'redis_exporter works idempotently with no errors' do
      pp = 'class { "prometheus::redis_exporter": version => "0.11.2" }'
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('redis_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
    # the class installs an the redis_exporter that listens on port 9121
    describe port(9121) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is version v0.11.2' do
      shell('curl -s http://127.0.0.1:9121/metrics') do |r|
        redis_exporter_build_info = r.stdout.split(%r{\n}).find { |line| line =~ %r{^redis_exporter_build_info} }
        expect(redis_exporter_build_info).to match(%r{,version="v0\.11\.2"})
      end
    end
  end
end
