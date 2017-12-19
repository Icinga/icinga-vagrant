require 'spec_helper'

describe('icinga2::object::notification', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {:target =>  '/bar/baz'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Notification "bar"/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::Notification::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with notification_name => foo" do
      let(:params) { {:notification_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Notification "foo"/) }
    end


    context "#{os} with host_name => foo" do
      let(:params) { {:host_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/host_name = "foo"/) }
    end


    context "#{os} with service_name => foo" do
      let(:params) { {:service_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/service_name = "foo"/) }
    end


    context "#{os} with vars => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/vars.foo = "bar"/)
                              .with_content(/vars.bar = "foo"/) }
    end


    context "#{os} with users => [foo, bar]" do
      let(:params) { {:users => ['foo','bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/users = \[ "foo", "bar", \]/) }
    end


    context "#{os} with users => host.vars.notification.mail.users" do
      let(:params) { {:users => 'host.vars.notification.mail.users', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/users = host\.vars\.notification\.mail\.users/) }
    end


    context "#{os} with user_groups => [foo, bar]" do
      let(:params) { {:user_groups => ['foo','bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/user_groups = \[ "foo", "bar", \]/) }
    end


    context "#{os} with user_groups => host.vars.notification.mail.groups" do
      let(:params) { {:user_groups => 'host.vars.notification.mail.groups', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/user_groups = host\.vars\.notification\.mail\.groups/) }
    end


    context "#{os} with times => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:times => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/times = {\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}/) }
    end


    context "#{os} with times => 'foo' (not a valid hash)" do
      let(:params) { {:times => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with command => foo" do
      let(:params) { {:command => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/command = "foo"/) }
    end


    context "#{os} with interval => 30" do
      let(:params) { {:interval => '30', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/interval = 30/) }
    end


    context "#{os} with interval => 30m" do
      let(:params) { {:interval => '30m', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/interval = 30m/) }
    end


    context "#{os} with interval => foo (not a valid integer)" do
      let(:params) { {:interval => 'foo', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with period => foo" do
      let(:params) { {:period => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/period = "foo"/) }
    end


    context "#{os} with zone => foo" do
      let(:params) { {:zone => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/zone = "foo"/) }
    end


    context "#{os} with types => [foo, bar]" do
      let(:params) { {:types => ['foo','bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/types = \[ "foo", "bar", \]/) }
    end


    context "#{os} with states => [foo, bar]" do
      let(:params) { {:states => ['foo','bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/states = \[ "foo", "bar", \]/) }
    end


    context "#{os} with assign => [] and ignore => [ foo ]" do
      let(:params) { {:assign => [], :ignore => ['foo'], :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /When attribute ignore is used, assign must be set/) }
    end
  end
end

describe('icinga2::object::notification', :type => :define) do
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
    let(:params) { {:target =>  'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Notification "bar"/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::Notification::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with notification_name => foo" do
    let(:params) { {:notification_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Notification "foo"/) }
  end


  context "Windows 2012 R2 with host_name => foo" do
    let(:params) { {:host_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/host_name = "foo"/) }
  end


  context "Windows 2012 R2 with service_name => foo" do
    let(:params) { {:service_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/service_name = "foo"/) }
  end


  context "Windows 2012 R2 with vars => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/vars.foo = "bar"/)
                            .with_content(/vars.bar = "foo"/) }
  end


  context "Windows 2012 R2 with users => [foo, bar]" do
    let(:params) { {:users => ['foo','bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/users = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with users => host.vars.notification.mail.users" do
    let(:params) { {:users => 'host.vars.notification.mail.users', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/users = host\.vars\.notification\.mail\.users/) }
  end


  context "Windows 2012 R2 with user_groups => [foo, bar]" do
    let(:params) { {:user_groups => ['foo','bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/user_groups = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with user_groups => host.vars.notification.mail.groups" do
    let(:params) { {:user_groups => 'host.vars.notification.mail.groups', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/user_groups = host\.vars\.notification\.mail\.groups/) }
  end


  context "Windows 2012 R2 with times => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:times => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/times = {\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}/) }
  end


  context "Windows 2012 R2 with times => 'foo' (not a valid hash)" do
    let(:params) { {:times => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with command => foo" do
    let(:params) { {:command => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/command = "foo"/) }
  end


  context "Windows 2012 R2 with interval => 30" do
    let(:params) { {:interval => '30', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/interval = 30/) }
  end


  context "Windows 2012 R2 with interval => 30m" do
    let(:params) { {:interval => '30m', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/interval = 30m/) }
  end


  context "Windows 2012 R2 with interval => foo (not a valid integer)" do
    let(:params) { {:interval => 'foo', :target => '/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with period => foo" do
    let(:params) { {:period => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/period = "foo"/) }
  end


  context "Windows 2012 R2 with zone => foo" do
    let(:params) { {:zone => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/zone = "foo"/) }
  end


  context "Windows 2012 R2 with types => [foo, bar]" do
    let(:params) { {:types => ['foo','bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/types = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with states => [foo, bar]" do
    let(:params) { {:states => ['foo','bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Notification::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/states = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with assign => [] and ignore => [ foo ]" do
    let(:params) { {:assign => [], :ignore => ['foo'], :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /When attribute ignore is used, assign must be set/) }
  end
end
