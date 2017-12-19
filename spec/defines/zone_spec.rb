require 'spec_helper'

describe('icinga2::object::zone', :type => :define) do
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

      it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/object Zone "bar"/) }
    end


   context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent', :target => '/bar/baz'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.not_to contain_concat__fragment('icinga2::object::Zone::bar') }
    end


    context "#{os} with ensure => foo (not a valid value)" do
      let(:params) { {:ensure => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
    end


    context "#{os} with target => bar/baz (not valid absolute path)" do
      let(:params) { {:target => 'bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
    end


    context "#{os} with endpoints => [NodeName, Host1]" do
      let(:params) { {:endpoints => ['NodeName','Host1'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
        .with_content(/endpoints = \[ NodeName, "Host1", \]/) }
    end


    context "#{os} with endpoints => foo (not a valid array)" do
      let(:params) { {:endpoints => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end


    context "#{os} with parent => foo" do
      let(:params) { {:parent => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
        .with_content(/parent = "foo"/) }
    end


    context "#{os} with global => true" do
      let(:params) { {:global => true, :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
        .with_content(/global = true/) }
    end


    context "#{os} with global => foo (not a valid boolean)" do
      let(:params) { {:global => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end
  end
end

describe('icinga2::object::zone', :type => :define) do
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

  context "Windows 2012 R2 with all defaults and target => C:/bar/baz" do
    let(:params) { {:target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Zone "bar"/) }
  end


  context "Windows 2012 R2 with ensure => absent" do
    let(:params) { {:ensure => 'absent', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.not_to contain_concat__fragment('icinga2::object::Zone::bar') }
  end


  context "Windows 2012 R2 with ensure => foo (not a valid value)" do
    let(:params) { {:ensure => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
  end


  context "Windows 2012 R2 with target => bar/baz (not valid absolute path)" do
    let(:params) { {:target => 'bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
  end


  context "Windows 2012 R2 with endpoints => [NodeName, Host1]" do
    let(:params) { {:endpoints => ['NodeName','Host1'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
                            .with_content(/endpoints = \[ NodeName, "Host1", \]/) }
  end


  context "Windows 2012 R2 with endpoints => foo (not a valid array)" do
    let(:params) { {:endpoints => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end


  context "Windows 2012 R2 with parent => foo" do
    let(:params) { {:parent => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
                            .with_content(/parent = "foo"/) }
  end


  context "Windows 2012 R2 with global => true" do
    let(:params) { {:global => true, :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Zone::bar')
                            .with_content(/global = true/) }
  end


  context "ws 2012 R2 with global => foo (not a valid boolean)" do
    let(:params) { {:global => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end
end