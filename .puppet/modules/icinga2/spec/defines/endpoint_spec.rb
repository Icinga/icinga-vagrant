require 'spec_helper'

describe('icinga2::object::endpoint', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
    "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {:target => '/bar/baz'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/object Endpoint "bar"/) }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent', :target => '/bar/baz'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.not_to contain_concat__fragment('icinga2::object::Endpoint::bar') }
    end


    context "#{os} with ensure => foo (not a valid value)" do
      let(:params) { {:ensure => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
    end


    context "#{os} with target => bar/baz (not valid absolute path)" do
      let(:params) { {:target => 'bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
    end


    context "#{os} with host => foo.example.com" do
      let(:params) { {:host => 'foo.example.com', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
        .with_content(/host = "foo.example.com"/) }
    end


    context "#{os} with port => 4247" do
      let(:params) { {:port => '4247', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
        .with_content(/port = 4247/) }
    end


    context "#{os} with port => foo (not a valid integer)" do
      let(:params) { {:port => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with log_duration => 1m" do
      let(:params) { {:log_duration => '1m', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
        .with_content(/log_duration = 1m/) }
    end


    context "#{os} with log_duration => foo (not a valid value)" do
      let(:params) { {:log_duration => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end
  end
end


describe('icinga2::object::endpoint', :type => :define) do
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
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  context "Windows 2012 R2  with all defaults and target => C:/bar/baz" do
    let(:params) { {:target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Endpoint "bar"/) }
  end


  context "Windows 2012 R2 with ensure => absent" do
    let(:params) { {:ensure => 'absent', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.not_to contain_concat__fragment('icinga2::object::Endpoint::bar') }
  end


  context "Windows 2012 R2 with ensure => foo (not a valid value)" do
    let(:params) { {:ensure => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
  end


  context "Windows 2012 R2  with target => bar/baz (not valid absolute path)" do
    let(:params) { {:target => 'bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
  end


  context "Windows 2012 R2  with host => foo.example.com" do
    let(:params) { {:host => 'foo.example.com', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
                            .with_content(/host = "foo.example.com"/) }
  end


  context "Windows 2012 R2  with port => 4247" do
    let(:params) { {:port => '4247', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
                            .with_content(/port = 4247/) }
  end


  context "Windows 2012 R2  with port => foo (not a valid integer)" do
    let(:params) { {:port => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2  with log_duration => 1m" do
    let(:params) { {:log_duration => '1m', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Endpoint::bar')
                            .with_content(/log_duration = 1m/) }
  end


  context "Windows 2012 R2  with log_duration => foo (not a valid value)" do
    let(:params) { {:log_duration => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end
end
