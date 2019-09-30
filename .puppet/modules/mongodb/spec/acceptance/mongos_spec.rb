require 'spec_helper_acceptance'

describe 'mongodb::mongos class' do
  config_file = if fact('osfamily') == 'RedHat'
                  '/etc/mongos.conf'
                else
                  '/etc/mongodb-shard.conf'
                end

  describe 'installation' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mongodb::server':
          configsvr => true,
        }
        -> class { 'mongodb::client': }
        -> class { 'mongodb::mongos':
          configdb => ['127.0.0.1:27019'],
        }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('mongodb-server') do
      it { is_expected.to be_installed }
    end

    describe file(config_file) do
      it { is_expected.to be_file }
    end

    describe service('mongos') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(27_017) do
      it { is_expected.to be_listening }
    end

    describe port(27_019) do
      it { is_expected.to be_listening }
    end

    describe command('mongo --version') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'uninstalling' do
    it 'uninstalls mongodb' do
      pp = <<-EOS
        class { 'mongodb::server':
          ensure         => absent,
          package_ensure => absent,
          service_ensure => stopped,
          service_enable => false
        }
        -> class { 'mongodb::client':
          ensure => absent,
        }
        -> class { 'mongodb::mongos':
          package_ensure => 'purged',
        }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('mongodb-server') do
      it { is_expected.not_to be_installed }
    end

    describe service('mongos') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe port(27_017) do
      it { is_expected.not_to be_listening }
    end

    describe port(27_019) do
      it { is_expected.not_to be_listening }
    end
  end
end
