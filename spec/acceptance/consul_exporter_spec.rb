require 'spec_helper_acceptance'

describe 'prometheus consul exporter' do
  it 'consul_exporter works idempotently with no errors' do
    pp = 'include prometheus::consul_exporter'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe 'prometheus consul exporter version 0.3.0' do
    it ' consul_exporter installs with version 0.3.0' do
      pp = "class {'prometheus::consul_exporter': version => '0.3.0' }"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('consul_exporter') do
      its(:args) { is_expected.to match %r{\ -consul.server} }
    end
    describe service('consul_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9107) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end

  describe 'prometheus consul exporter version 0.5.0' do
    it ' consul_exporter installs with version 0.5.0' do
      pp = "class {'prometheus::consul_exporter': version => '0.5.0' }"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe process('consul_exporter') do
      its(:args) { is_expected.to match %r{\ --consul.server} }
    end
    describe service('consul_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9107) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
