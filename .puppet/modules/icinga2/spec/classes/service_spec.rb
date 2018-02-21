require 'spec_helper'

describe('icinga2', :type => :class) do
  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with ensure => running, enable => true" do
      let(:params) { {:ensure => 'running', :enable => true} }
      it do
        should contain_service('icinga2').with({
          'ensure' => 'running',
          'enable' => true,
        })
      end
    end

    context "#{os} with ensure => stopped, enable => false" do
      let(:params) { {:ensure => 'stopped', :enable => false} }
      it do
        should contain_service('icinga2').with({
          'ensure' => 'stopped',
          'enable' => false,
        })
      end
    end

    context "#{os} with ensure => foo (not a valid boolean)" do
      let(:params) { {:ensure => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported. Valid values are 'running' and 'stopped'./) }
    end

    context "#{os} with enable => foo (not a valid boolean)" do
      let(:params) { {:enable => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end

    context "#{os} with manage_service => true" do
      let(:params) { {:manage_service => true} }
      it { should contain_service('icinga2') }
    end

    context "#{os} with manage_service => false" do
      let(:params) { {:manage_service => false} }
      it { should_not contain_service('icinga2') }
    end

    context "#{os} with manage_service => foo (not a valid boolean)" do
      let(:params) { {:manage_service => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end
  end
end



describe('icinga2', :type => :class) do
  let(:facts) { {
    :kernel => 'Windows',
    :architecture => 'x86_64',
    :osfamily => 'Windows',
    :operatingsystem => 'Windows',
    :operatingsystemmajrelease => '2012 R2'
  } }

  context "windows with ensure => running, enable => true" do
    let(:params) { {:ensure => 'running', :enable => true} }
    it do
      should contain_service('icinga2').with({
        'ensure' => 'running',
        'enable' => true,
      })
    end
  end

  context "windows with ensure => stopped, enable => false" do
    let(:params) { {:ensure => 'stopped', :enable => false} }
    it do
      should contain_service('icinga2').with({
        'ensure' => 'stopped',
        'enable' => false,
      })
    end
  end

  context "windows with ensure => foo (not a valid boolean)" do
    let(:params) { {:ensure => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported. Valid values are 'running' and 'stopped'./) }
  end

  context "windows with enable => foo (not a valid boolean)" do
    let(:params) { {:enable => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end

  context "windows with manage_service => true" do
    let(:params) { {:manage_service => true} }

    it { should contain_service('icinga2') }
  end

  context "windows with manage_service => false" do
    let(:params) { {:manage_service => false} }

    it { should_not contain_service('icinga2') }
  end

  context "windows with manage_service => foo (not a valid boolean)" do
    let(:params) { {:manage_service => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end
end
