require 'spec_helper'

describe('icingaweb2::config', :type => :class) do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with default parameters' do
        let :pre_condition do
          "class { 'icingaweb2': }"
        end

        it { is_expected.to contain_icingaweb2__inisection('logging') }
        it { is_expected.to contain_icingaweb2__inisection('global')
          .with_settings({ 'show_stacktraces' => false, 'module_path' => '/usr/share/icingaweb2/modules', 'config_backend' => 'ini' })
        }
        it { is_expected.to contain_icingaweb2__inisection('themes') }
        it { is_expected.to contain_file('/var/log/icingaweb2')
          .with_ensure('directory')
          .with_mode('0750')
        }
        it { is_expected.to contain_file('/var/log/icingaweb2/icingaweb2.log')
          .with_ensure('file')
          .with_mode('0640')
        }
      end

      context 'with import_schema => true and db_type => mysql' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'mysql'}"
        end

        it { is_expected.to contain_icingaweb2__config__resource('mysql-icingaweb2')}
        it { is_expected.to contain_icingaweb2__config__authmethod('mysql-auth')}
        it { is_expected.to contain_icingaweb2__config__role('default admin user')}
        it { is_expected.to contain_exec('import schema') }
        it { is_expected.to contain_exec('create default user') }
      end

      context 'with import_schema => true and db_type => pgsql' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'pgsql'}"
        end

        it { is_expected.to contain_icingaweb2__config__resource('pgsql-icingaweb2')}
        it { is_expected.to contain_icingaweb2__config__authmethod('pgsql-auth')}
        it { is_expected.to contain_icingaweb2__config__role('default admin user')}
        it { is_expected.to contain_exec('import schema') }
        it { is_expected.to contain_exec('create default user') }
      end

      context 'with import_schema => true and invalid db_type' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => true, db_type => 'foobar'}"
        end

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['mysql', 'pgsql'\]/) }
      end

      context 'with import_schema => false' do
        let :pre_condition do
          "class { 'icingaweb2': import_schema => false }"
        end

        it { is_expected.not_to contain_exec('import schema')}
        it { is_expected.not_to contain_exec('create default user')}
        it { is_expected.not_to contain_icingaweb2__config__role('default admin user')}
      end

      context 'with config_backend => db' do
        let :pre_condition do
          "class { 'icingaweb2': config_backend => 'db' }"
        end

        it { is_expected.to contain_icingaweb2__inisection('global')
          .with_settings({ 'show_stacktraces' => false, 'module_path' => '/usr/share/icingaweb2/modules', 'config_backend' => 'db', 'config_resource' => 'mysql-icingaweb2' })
        }

        it { is_expected.to contain_icingaweb2__config__resource('mysql-icingaweb2')}
      end

      context 'with invalid config_backend' do
        let :pre_condition do
          "class { 'icingaweb2': config_backend => 'foobar' }"
        end

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['db', 'ini'\]/) }
      end
    end
  end
end
