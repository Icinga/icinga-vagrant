require 'spec_helper'

describe('icinga2::object::apiuser', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
    "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with all defaults and permissions => ['*'], target => /bar/baz" do
      let(:params) { {:target =>  '/bar/baz', :permissions => ['*']} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/object ApiUser "bar"/)
        .with_content(/permissions = \[ "\*", \]/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::ApiUser::bar')
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with target => bar/baz (not valid absolute path)" do
      let(:params) { {:target => 'bar/baz', :permissions => ['*']} }

      it { is_expected.to raise_error(Puppet::Error, /"bar\/baz" is not an absolute path/) }
    end


    context "#{os} with password => foo" do
      let(:params) { {:password => 'foo', :permissions => ['*'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/password = "foo"/) }
    end


    context "#{os} with client_cn => foo" do
      let(:params) { {:client_cn => 'foo', :permissions => ['*'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/client_cn = "foo"/) }
    end


    context "#{os} with permissions => [foo, bar]" do
      let(:params) { {:permissions => ['foo', 'bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/permissions = \[ "foo", "bar", \]/) }
    end


    context "#{os} with permissions => foo (not a valid array)" do
      let(:params) { {:permissions => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end
  end
end

describe('icinga2::object::apiuser', :type => :define) do
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

  context "Windows 2012 R2  with all defaults and permissions => ['*'], target => C:/bar/baz" do
    let(:params) { {:target =>  'C:/bar/baz', :permissions => ['*']} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object ApiUser "bar"/)
                            .with_content(/permissions = \[ "\*", \]/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::ApiUser::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2  with target => C:bar/baz (not valid absolute path)" do
    let(:params) { {:target => 'C:bar/baz', :permissions => ['*']} }

    it { is_expected.to raise_error(Puppet::Error, /"C:bar\/baz" is not an absolute path/) }
  end


  context "Windows 2012 R2  with password => foo" do
    let(:params) { {:password => 'foo', :permissions => ['*'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/password = "foo"/) }
  end


  context "Windows 2012 R2  with client_cn => foo" do
    let(:params) { {:client_cn => 'foo', :permissions => ['*'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/client_cn = "foo"/) }
  end


  context "Windows 2012 R2  with permissions => [foo, bar]" do
    let(:params) { {:permissions => ['foo', 'bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiUser::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/permissions = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2  with permissions => foo (not a valid array)" do
    let(:params) { {:permissions => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end
end