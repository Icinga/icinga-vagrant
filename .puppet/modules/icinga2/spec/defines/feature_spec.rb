require 'spec_helper'

describe('icinga2::feature', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) do
    [
      "class { 'icinga2': features => [], }",
      # config file will be created by any feature class
      "icinga2::object { 'icinga2::feature::foo':
        object_name => 'foo',
        object_type => 'FooComponent',
        target      => '/etc/icinga2/features-available/foo.conf',
        order       => '10',
      }"
    ]
  end


  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with ensure => foo (not a valid value)" do
      let(:params) { {:ensure => 'foo'} }

      it do
        expect {
          should contain_icinga2__feature('foo')
        }.to raise_error(Puppet::Error, /foo isn't supported. Valid values are 'present' and 'absent'./)
      end
    end


    context "#{os} with ensure => present, feature => foo" do
      let(:params) { {:ensure => 'present', :feature => 'foo'} }

      it {
        should contain_file('/etc/icinga2/features-enabled/foo.conf').with({
          'ensure' => 'link',
        }).that_notifies('Class[icinga2::service]')
      }
    end


    context "#{os} with ensure => absent, feature => foo" do
      let(:params) { {:ensure => 'absent', :feature => 'foo'} }

      it {
        should contain_file('/etc/icinga2/features-enabled/foo.conf').with({
          'ensure' => 'absent',
        }).that_notifies('Class[icinga2::service]')
      }
    end
  end
end

describe('icinga2::feature', :type => :define) do
  let(:facts) { {
      :kernel => 'Windows',
      :architecture => 'x86_64',
      :osfamily => 'Windows',
      :operatingsystem => 'Windows',
      :operatingsystemmajrelease => '2012 R2',
      :path => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\facter\bin;
               C:\Program Files\Puppet Labs\Puppet\hiera\bin;
               C:\Program Files\Puppet Labs\Puppet\mcollective\bin;
               C:\Program Files\Puppet Labs\Puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\tools\bin;
               C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;
               C:\Windows\System32\WindowsPowerShell\v1.0\;
               C:\ProgramData\chocolatey\bin;',
  } }
  let(:title) { 'bar' }
  let(:pre_condition) do
    [
      "class { 'icinga2': features => [], }",
      # config file will be created by any feature class
      "icinga2::object { 'icinga2::feature::foo':
        object_name => 'foo',
        object_type => 'FooComponent',
        target      => 'C:/ProgramData/icinga2/etc/icinga2/features-available/foo.conf',
        order       => '10',
      }"
    ]
  end

  context 'Windows 2012 R2 with ensure => present, feature => foo' do
    let(:params) { {:ensure => 'present', 'feature' => 'foo'} }

    it {
      should contain_file('C:/ProgramData/icinga2/etc/icinga2/features-enabled/foo.conf')
                 .with({'ensure' => 'file',})
                 .with_content(/include "..\/features-available\/foo.conf"/)
                 .that_notifies('Class[icinga2::service]')
    }
  end


  context 'Windows 2012 R2 with ensure => absent, feature => foo' do
    let(:params) { {:ensure => 'absent', 'feature' => 'foo'} }

    it {
      should contain_file('C:/ProgramData/icinga2/etc/icinga2/features-enabled/foo.conf')
                 .with({'ensure' => 'absent',})
                 .that_notifies('Class[icinga2::service]')
    }
  end
end