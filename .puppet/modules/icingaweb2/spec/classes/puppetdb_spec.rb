require 'spec_helper'

describe('icingaweb2::module::puppetdb', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "with ensure present, git_revision, ssl and certificates to their defaults" do
        let(:params) { { :ensure => 'present', } }

        it { is_expected.to contain_icingaweb2__module('puppetdb')
          .with_ensure('present')
          .with_install_method('git')
          .with_git_repository('https://github.com/Icinga/icingaweb2-module-puppetdb.git')
          .with_git_revision('master')
          .with_module_dir('/usr/share/icingaweb2/modules/puppetdb')
                         }

        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }

        it { is_expected.to have_icingaweb2__module__puppetdb__certificate_resource_count(0) }
      end

      context "with ensure absent" do
        let(:params) { { :ensure => 'absent', } }

        it { is_expected.to contain_icingaweb2__module('puppetdb')
          .with_ensure('absent')
                         }
      end

      context "with ensure foo" do
        let(:params) { { :ensure => 'foo' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['absent', 'present'\]/) }
      end

      context "with ensure absent" do
        let(:params) { { :ensure => 'absent', } }

        it { is_expected.to contain_icingaweb2__module('puppetdb')
          .with_ensure('absent')
                         }

        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }
        it { is_expected.not_to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb') }

      end

      context "with git_revision set to 123" do
        let(:params) { { :git_revision => '123', } }

        it { is_expected.to contain_icingaweb2__module('puppetdb')
          .with_ensure('present')
          .with_git_revision('123')
                         }
      end

      context "with ssl set to none" do
        let(:params) { { :ssl => 'none', } }

        it { is_expected.to contain_icingaweb2__module('puppetdb') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }

        it { is_expected.not_to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb') }
      end

      context "with ssl set to none and two certificates" do
        let(:params) { { :ssl => 'none',
                         :certificates => { 'pupdb1' =>
                                              { 'ssl_key' => 'mysslkey1', 'ssl_cacert' => 'mycacert1'},
                                            'pupdb2' => 
                                              { 'ssl_key' => 'mysslkey2', 'ssl_cacert' => 'mycacert2'},
                                          }
                         } }

        it { is_expected.to contain_icingaweb2__module('puppetdb') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }
        it { is_expected.to have_icingaweb2__module__puppetdb__certificate_resource_count(2) }
        it { is_expected.to contain_icingaweb2__module__puppetdb__certificate('pupdb1')
          .with_ssl_key('mysslkey1')
          .with_ssl_cacert('mycacert1')
                         }
        it { is_expected.to contain_icingaweb2__module__puppetdb__certificate('pupdb2')
          .with_ssl_key('mysslkey2')
          .with_ssl_cacert('mycacert2')
                         }
      end

      context "with ssl set to puppet and no extra certificates" do
        let(:params) { { :ssl => 'puppet',
                        } }

        it { is_expected.to contain_icingaweb2__module('puppetdb') }

        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb')
          .with_ensure('directory')
                         }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys')
          .with_ensure('directory')
                         }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/certs')
          .with_ensure('directory')
                         }

        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/certs/ca.pem')
          .with_ensure('present')
          .with_mode('0640')
          .with_source('/etc/puppet/ssl/certs/ca.pem')
                         }

        it { is_expected.to have_icingaweb2__module__puppetdb__certificate_resource_count(0) }

        it { is_expected.to contain_concat('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_ensure('present')
          .with_warn('false')
          .with_mode('0640')
          .with_ensure_newline(true)
                        }

        it { is_expected.to contain_concat__fragment('private_key')
          .with_target('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_source('/etc/puppet/ssl/private_keys/foo.example.com.pem')
          .with_order('1')
                        }

        it { is_expected.to contain_concat__fragment('public_key')
          .with_target('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_source('/etc/puppet/ssl/certs/foo.example.com.pem')
          .with_order('2')
                        }
      end

      context "with ssl set to puppet and one extra certificate" do
        let(:params) { { :ssl => 'puppet',
                         :certificates => { 'pupdb1' =>
                                              { 'ssl_key' => 'mysslkey1', 'ssl_cacert' => 'mycacert1'},
                                          },
                         } }

        it { is_expected.to contain_icingaweb2__module('puppetdb') }
        it { is_expected.to contain_file('/etc/icingaweb2/modules/puppetdb/ssl')
          .with_ensure('directory')
                         }
        it { is_expected.to have_icingaweb2__module__puppetdb__certificate_resource_count(1) }

        it { is_expected.to contain_icingaweb2__module__puppetdb__certificate('pupdb1')
          .with_ssl_key('mysslkey1')
          .with_ssl_cacert('mycacert1')
                         }

        it { is_expected.to contain_concat('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_ensure('present')
          .with_warn('false')
          .with_mode('0640')
          .with_ensure_newline(true)
                        }

        it { is_expected.to contain_concat__fragment('private_key')
          .with_target('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_order('1')
                        }

        it { is_expected.to contain_concat__fragment('public_key')
          .with_target('/etc/icingaweb2/modules/puppetdb/ssl/puppetdb/private_keys/puppetdb_combined.pem')
          .with_order('2')
                        }
      end

      context "with ssl set to foo" do
        let(:params) { { :ssl => 'foo' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['none', 'puppet'\]/) }
      end
    end
  end
end

