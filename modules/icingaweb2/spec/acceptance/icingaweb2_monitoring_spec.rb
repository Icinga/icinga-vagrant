#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'icingaweb2::module::monitoring class:' do
  it 'runs successfully' do
    pp = "
      include ::mysql::server

      mysql::db { 'icingaweb2':
        user     => 'icingaweb2',
        password => 'icingaweb2',
        host     => 'localhost',
        grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
      }

      class {'icingaweb2':
        manage_repo   => true,
        import_schema => true,
        db_type       => 'mysql',
        db_host       => 'localhost',
        db_port       => 3306,
        db_username   => 'icingaweb2',
        db_password   => 'icingaweb2',
        require       => Mysql::Db['icingaweb2'],
      }

      class {'icingaweb2::module::monitoring':
        ido_host        => 'localhost',
        ido_db_name     => 'icinga2',
        ido_db_username => 'icinga2',
        ido_db_password => 'supersecret',
        commandtransports => {
          icinga2 => {
            transport => 'api',
            username  => 'root',
            password  => 'icinga',
          }
        }
      }
    "

    apply_manifest(pp, catch_failures: true)
  end

  describe file('/etc/icingaweb2/enabledModules/monitoring') do
    it { is_expected.to be_symlink }
  end

  describe file('/etc/icingaweb2/modules/monitoring/security.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[security]' }
    it { is_expected.to contain 'protected_customvars = "*pw*,*pass*,community"' }
  end

  describe file('/etc/icingaweb2/modules/monitoring/backends.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[backends]' }
    it { is_expected.to contain 'type = "ido"' }
    it { is_expected.to contain 'resource = "icingaweb2-module-monitoring"' }
  end

  describe file('/etc/icingaweb2/modules/monitoring/commandtransports.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[icinga2]' }
    it { is_expected.to contain 'transport = "api"' }
    it { is_expected.to contain 'host = "localhost"' }
    it { is_expected.to contain 'port = "5665"' }
    it { is_expected.to contain 'username = "root"' }
    it { is_expected.to contain 'password = "icinga"' }
  end

  describe file('/etc/icingaweb2/resources.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[icingaweb2-module-monitoring]' }
    it { is_expected.to contain 'type = "db"' }
    it { is_expected.to contain 'db = "mysql"' }
    it { is_expected.to contain 'host = "localhost"' }
    it { is_expected.to contain 'port = "3306"' }
    it { is_expected.to contain 'dbname = "icinga2"' }
    it { is_expected.to contain 'username = "icinga2"' }
    it { is_expected.to contain 'password = "supersecret"' }
    it { is_expected.to contain '[mysql-icingaweb2]' }
    it { is_expected.to contain 'type = "db"' }
    it { is_expected.to contain 'db = "mysql"' }
    it { is_expected.to contain 'host = "localhost"' }
    it { is_expected.to contain 'port = "3306"' }
    it { is_expected.to contain 'dbname = "icingaweb2"' }
    it { is_expected.to contain 'username = "icingaweb2"' }
    it { is_expected.to contain 'password = "icingaweb2"' }
  end

  describe file('/etc/icingaweb2/authentication.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[mysql-auth]' }
    it { is_expected.to contain 'backend = "db"' }
    it { is_expected.to contain 'resource = "mysql-icingaweb2"' }

  end

  describe file('/etc/icingaweb2/roles.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[default admin user]' }
    it { is_expected.to contain 'users = "icingaadmin"' }
    it { is_expected.to contain 'permissions = "*"' }
  end

  describe command('mysql -e "select name from icingaweb2.icingaweb_user"') do
    its(:stdout) { should match(%r{icingaadmin}) }
  end
end
