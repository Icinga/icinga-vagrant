require 'spec_helper'

describe('icingaweb2::config::groupbackend', :type => :define) do
  let(:title) { 'mygroupbackend' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with backend 'db'" do
        let(:params) { { :backend => 'db', :resource => 'my-ldap' } }

        it { is_expected.to contain_icingaweb2__inisection('mygroupbackend')
          .with_target('/etc/icingaweb2/groups.ini')
          .with_settings({'backend'=>'db', 'resource' => 'my-ldap'})}

      end

      context "#{os} with backend 'ldap'" do
        let(:params) { { :backend => 'ldap', :resource => 'my-ldap', :ldap_group_class => 'groupofnames', :ldap_group_name_attribute => 'cn', :ldap_group_member_attribute => 'member', :ldap_base_dn => 'foobar', :domain => 'icinga.com' } }

        it { is_expected.to contain_icingaweb2__inisection('mygroupbackend')
          .with_target('/etc/icingaweb2/groups.ini')
          .with_settings({'backend'=>'ldap', 'resource'=>'my-ldap', 'group_class'=>'groupofnames', 'group_name_attribute'=>'cn', 'group_member_attribute'=>'member', 'base_dn'=>'foobar', 'domain' => 'icinga.com'})}
      end

      context "#{os} with backend 'msldap'" do
        let(:params) { { :backend => 'msldap', :resource => 'my-msldap', :ldap_user_backend => 'ad1', :ldap_nested_group_search => true, :ldap_group_filter => 'baz', :ldap_base_dn => 'foobar', :domain => 'icinga.com' } }

        it { is_expected.to contain_icingaweb2__inisection('mygroupbackend')
          .with_target('/etc/icingaweb2/groups.ini')
          .with_settings({'backend'=>'msldap', 'resource'=>'my-msldap', 'user_backend'=>'ad1', 'nested_group_search'=>'1', 'group_filter'=>'baz', 'base_dn'=>'foobar', 'domain' => 'icinga.com' })}
      end

      context "#{os} with invalid backend" do
        let(:params) { { :backend => 'foobar' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['db', 'ldap', 'msldap'\]/) }
      end
    end
  end
end
