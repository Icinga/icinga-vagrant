require 'spec_helper'

describe('icingaweb2::config::authmethod', :type => :define) do
  let(:title) { 'myauthmethod' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with backend 'external'" do
        let(:params) { { :backend => 'external', :order => '10' } }

        it { is_expected.to contain_icingaweb2__inisection('myauthmethod')
          .with_target('/etc/icingaweb2/authentication.ini')
          .with_settings({'backend'=>'external'})
          .with_order('10')}

      end

      context "#{os} with backend 'ldap'" do
        let(:params) { { :backend => 'ldap', :resource => 'myresource', :ldap_user_class => 'users', :ldap_user_name_attribute => 'uid', :ldap_filter => 'foobar', :domain => 'icinga.com', :order => '10' } }

        it { is_expected.to contain_icingaweb2__inisection('myauthmethod')
          .with_target('/etc/icingaweb2/authentication.ini')
          .with_settings({'backend'=>'ldap', 'resource'=>'myresource', 'user_class'=>'users', 'user_name_attribute'=>'uid', 'filter'=>'foobar', 'domain'=>'icinga.com' },  )
          .with_order('10')}
      end

      context "#{os} with backend 'msldap'" do
        let(:params) { { :backend => 'msldap', :resource => 'myresource', :order => '10' } }

        it { is_expected.to contain_icingaweb2__inisection('myauthmethod')
          .with_target('/etc/icingaweb2/authentication.ini')
          .with_settings({'backend'=>'msldap', 'resource'=>'myresource'})
          .with_order('10')}
      end

      context "#{os} with backend 'db'" do
        let(:params) { { :backend => 'db', :resource => 'myresource', :order => '10' } }

        it { is_expected.to contain_icingaweb2__inisection('myauthmethod')
          .with_target('/etc/icingaweb2/authentication.ini')
          .with_settings({'backend'=>'db', 'resource'=>'myresource'})
          .with_order('10')}
      end

      context "#{os} with invalid backend" do
        let(:params) { { :backend => 'foobar' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['db', 'external', 'ldap', 'msldap'\]/) }
      end
    end
  end
end
