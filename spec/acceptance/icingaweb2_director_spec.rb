#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'icingaweb2::module::director class:' do
  it 'runs successfully' do
    pp = "
      case $::osfamily {
        'redhat': {
          package { 'centos-release-scl':
            before => Class['icingaweb2']
          }
        }
      }

      package { 'git': }

      include ::mysql::server

      mysql::db { 'icingaweb2':
        user     => 'icingaweb2',
        password => 'icingaweb2',
        host     => 'localhost',
        grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
      }

      mysql::db { 'director':
        user     => 'director',
        password => 'director',
        host     => 'localhost',
        charset  => 'utf8',
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

      class {'icingaweb2::module::director':
        git_revision  => 'v1.3.2',
        db_host       => 'localhost',
        db_name       => 'director',
        db_username   => 'director',
        db_password   => 'director',
        import_schema => true,
        kickstart     => false,
        endpoint      => 'puppet-icingaweb2.localdomain',
        api_username  => 'root',
        api_password  => 'icinga',
        require       => Mysql::Db['director']
      }
    "

    apply_manifest(pp, catch_failures: true)
  end

  describe file('/etc/icingaweb2/enabledModules/director') do
    it { is_expected.to be_symlink }
  end

  describe file('/etc/icingaweb2/modules/director/config.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[db]' }
    it { is_expected.to contain 'resource = "icingaweb2-module-director"' }
  end

  describe file('/etc/icingaweb2/resources.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[icingaweb2-module-director]' }
    it { is_expected.to contain 'type = "db"' }
    it { is_expected.to contain 'db = "mysql"' }
    it { is_expected.to contain 'host = "localhost"' }
    it { is_expected.to contain 'port = "3306"' }
    it { is_expected.to contain 'dbname = "director"' }
    it { is_expected.to contain 'username = "director"' }
    it { is_expected.to contain 'password = "director"' }
    it { is_expected.to contain 'charset = "utf8"' }
  end

  #describe command('mysql -e "select object_name from director.icinga_apiuser"') do
  #  its(:stdout) { should match(%r{root}) }
  #end
end
