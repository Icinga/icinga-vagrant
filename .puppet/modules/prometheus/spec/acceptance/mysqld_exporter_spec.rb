require 'spec_helper_acceptance'

describe 'prometheus mysqld exporter' do
  it 'mysqld_exporter works idempotently with no errors' do
    pp = 'include prometheus::mysqld_exporter'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('mysqld_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  # the class installs an the mysqld_exporter that listens on port 9104
  describe port(9104) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'mysqld_exporter update from 0.9.0 to 0.12.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::mysqld_exporter': version => '0.9.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('mysqld_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9104) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::mysqld_exporter': version => '0.12.0'}"
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('mysqld_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9104) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    describe process('mysqld_exporter') do
      its(:args) { is_expected.to match %r{\ --config.my-cnf} }
    end
  end
end
