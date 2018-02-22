require 'spec_helper'

describe('icinga2::object::service', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {
          :target => '/bar/baz',
          :host_name => 'hostfoo',
          :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Service "bar"/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::Service::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with service_name => foo" do
      let(:params) { {:service_name => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Service "foo"/) }
    end


    context "#{os} with display_name => foo" do
      let(:params) { {:display_name => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/display_name = "foo"/) }
    end


    context "#{os} with host_name => foo" do
      let(:params) { {:host_name => 'foo', :target => '/bar/baz',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/host_name = "foo"/) }
    end


    context "#{os} with groups => [foo, bar]" do
      let(:params) { {:groups => ['foo','bar'], :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/groups = \[ "foo", "bar", \]/) }
    end


    context "#{os} with groups => foo (not a valid array)" do
      let(:params) { {:groups => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end

    context "#{os} with vars => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo' } }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/vars.foo = "bar"/)
                              .with_content(/vars.bar = "foo"/) }
    end


    context "#{os} with check_command => foo" do
      let(:params) { {:check_command => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/check_command = "foo"/) }
    end


    context "#{os} with max_check_attempts => 30" do
      let(:params) { {:max_check_attempts => '30', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/max_check_attempts = 30/) }
    end


    context "#{os} with max_check_attempts => foo (not a valid integer)" do
      let(:params) { {:max_check_attempts => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end



    context "#{os} with check_period => foo" do
      let(:params) { {:check_period => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/check_period = "foo"/) }
    end


    context "#{os} with check_interval => 1m" do
      let(:params) { {:check_interval => '1m', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/check_interval = 1m/) }
    end


    context "#{os} with check_interval => foo (not a valid value)" do
      let(:params) { {:check_interval => 'foo', :target => '/bar/baz', :check_command => 'foocommand'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with retry_interval => 30s" do
      let(:params) { {:retry_interval => '30s', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/retry_interval = 30s/) }
    end


    context "#{os} with retry_interval => foo (not a valid value)" do
      let(:params) { {:retry_interval => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with enable_notifications => false" do
      let(:params) { {:enable_notifications => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_notifications = false/) }
    end


    context "#{os} with enable_notifications => foo (not a valid boolean)" do
      let(:params) { {:enable_notifications => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_active_checks => false" do
      let(:params) { {:enable_active_checks => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_active_checks = false/) }
    end


    context "#{os} with enable_active_checks => foo (not a valid boolean)" do
      let(:params) { {:enable_active_checks => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_passive_checks => false" do
      let(:params) { {:enable_passive_checks => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_passive_checks = false/) }
    end


    context "#{os} with enable_passive_checks => foo (not a valid boolean)" do
      let(:params) { {:enable_passive_checks => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_event_handler => false" do
      let(:params) { {:enable_event_handler => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_event_handler = false/) }
    end


    context "#{os} with enable_event_handler => foo (not a valid boolean)" do
      let(:params) { {:enable_event_handler => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_flapping => false" do
      let(:params) { {:enable_flapping => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_flapping = false/) }
    end


    context "#{os} with enable_flapping => foo (not a valid boolean)" do
      let(:params) { {:enable_flapping => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_perfdata => false" do
      let(:params) { {:enable_perfdata => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/enable_perfdata = false/) }
    end


    context "#{os} with enable_perfdata => foo (not a valid boolean)" do
      let(:params) { {:enable_perfdata => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with event_command => foo" do
      let(:params) { {:event_command => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/event_command = "foo"/) }
    end


    context "#{os} with flapping_threshold => 30" do
      let(:params) { {:flapping_threshold => '30', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/flapping_threshold = 30/) }
    end


    context "#{os} with flapping_threshold => foo (not a valid integer)" do
      let(:params) { {:flapping_threshold => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with volatile => false" do
      let(:params) { {:volatile => false, :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/volatile = false/) }
    end


    context "#{os} with volatile => foo (not a valid boolean)" do
      let(:params) { {:volatile => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with zone => foo" do
      let(:params) { {:zone => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/zone = "foo"/) }
    end


    context "#{os} with command_endpoint => foo" do
      let(:params) { {:command_endpoint => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/command_endpoint = "foo"/) }
    end


    context "#{os} with notes => foo" do
      let(:params) { {:notes => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/notes = "foo"/) }
    end


    context "#{os} with notes_url => foo" do
      let(:params) { {:notes_url => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/notes_url = "foo"/) }
    end


    context "#{os} with action_url => foo" do
      let(:params) { {:action_url => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/action_url = "foo"/) }
    end


    context "#{os} with icon_image = /foo/bar" do
      let(:params) { {:icon_image => '/foo/bar', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/icon_image = "\/foo\/bar"/) }
    end


    context "#{os} with icon_image = foo/bar (not a valid absolute path)" do
      let(:params) { {:icon_image => 'foo/bar', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with icon_image_alt => foo" do
      let(:params) { {:icon_image_alt => 'foo', :target => '/bar/baz',
                      :host_name => 'hostfoo',
                      :check_command => 'commandfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/icon_image_alt = "foo"/) }
    end
  end
end

describe('icinga2::object::service', :type => :define) do
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
    let(:params) { {
        :target => 'C:/bar/baz',
        :host_name => 'hostfoo',
        :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Service "bar"/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::Service::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with service_name => foo" do
    let(:params) { {:service_name => 'foo', :target => 'C:/bar/baz',
                        :host_name => 'hostfoo',
                        :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                        .with({'target' => 'C:/bar/baz'})
                        .with_content(/object Service "foo"/) }
  end


  context "Windows 2012 R2 with display_name => foo" do
    let(:params) { {:display_name => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/display_name = "foo"/) }
  end


  context "Windows 2012 R2 with host_name => foo" do
    let(:params) { {:host_name => 'foo', :target => 'C:/bar/baz',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/host_name = "foo"/) }
  end


  context "Windows 2012 R2 with groups => [foo, bar]" do
    let(:params) { {:groups => ['foo','bar'], :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/groups = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with groups => foo (not a valid array)" do
    let(:params) { {:groups => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end

  context "Windows 2012 R2 with vars => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo' } }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/vars.foo = "bar"/)
                            .with_content(/vars.bar = "foo"/) }
  end


  context "Windows 2012 R2 with check_command => foo" do
    let(:params) { {:check_command => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/check_command = "foo"/) }
  end


  context "Windows 2012 R2 with max_check_attempts => 30" do
    let(:params) { {:max_check_attempts => '30', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/max_check_attempts = 30/) }
  end


  context "Windows 2012 R2 with max_check_attempts => foo (not a valid integer)" do
    let(:params) { {:max_check_attempts => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with check_period => foo" do
    let(:params) { {:check_period => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/check_period = "foo"/) }
  end


  context "Windows 2012 R2 with check_interval => 1m" do
    let(:params) { {:check_interval => '1m', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/check_interval = 1m/) }
  end


  context "Windows 2012 R2 with check_interval => foo (not a valid value)" do
    let(:params) { {:check_interval => 'foo', :target => 'C:/bar/baz', :check_command => 'foocommand'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with retry_interval => 30s" do
    let(:params) { {:retry_interval => '30s', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/retry_interval = 30s/) }
  end


  context "Windows 2012 R2 with retry_interval => foo (not a valid value)" do
    let(:params) { {:retry_interval => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with enable_notifications => false" do
    let(:params) { {:enable_notifications => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_notifications = false/) }
  end


  context "Windows 2012 R2 with enable_notifications => foo (not a valid boolean)" do
    let(:params) { {:enable_notifications => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_active_checks => false" do
    let(:params) { {:enable_active_checks => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_active_checks = false/) }
  end


  context "Windows 2012 R2 with enable_active_checks => foo (not a valid boolean)" do
    let(:params) { {:enable_active_checks => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_passive_checks => false" do
    let(:params) { {:enable_passive_checks => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_passive_checks = false/) }
  end


  context "Windows 2012 R2 with enable_passive_checks => foo (not a valid boolean)" do
    let(:params) { {:enable_passive_checks => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_event_handler => false" do
    let(:params) { {:enable_event_handler => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_event_handler = false/) }
  end


  context "Windows 2012 R2 with enable_event_handler => foo (not a valid boolean)" do
    let(:params) { {:enable_event_handler => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_flapping => false" do
    let(:params) { {:enable_flapping => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_flapping = false/) }
  end


  context "Windows 2012 R2 with enable_flapping => foo (not a valid boolean)" do
    let(:params) { {:enable_flapping => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_perfdata => false" do
    let(:params) { {:enable_perfdata => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/enable_perfdata = false/) }
  end


  context "Windows 2012 R2 with enable_perfdata => foo (not a valid boolean)" do
    let(:params) { {:enable_perfdata => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with event_command => foo" do
    let(:params) { {:event_command => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/event_command = "foo"/) }
  end


  context "Windows 2012 R2 with flapping_threshold => 30" do
    let(:params) { {:flapping_threshold => '30', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/flapping_threshold = 30/) }
  end


  context "Windows 2012 R2 with flapping_threshold => foo (not a valid integer)" do
    let(:params) { {:flapping_threshold => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with volatile => false" do
    let(:params) { {:volatile => false, :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/volatile = false/) }
  end


  context "Windows 2012 R2 with volatile => foo (not a valid boolean)" do
    let(:params) { {:volatile => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with zone => foo" do
    let(:params) { {:zone => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/zone = "foo"/) }
  end


  context "Windows 2012 R2 with command_endpoint => foo" do
    let(:params) { {:command_endpoint => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/command_endpoint = "foo"/) }
  end


  context "Windows 2012 R2 with notes => foo" do
    let(:params) { {:notes => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/notes = "foo"/) }
  end


  context "Windows 2012 R2 with notes_url => foo" do
    let(:params) { {:notes_url => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/notes_url = "foo"/) }
  end


  context "Windows 2012 R2 with action_url => foo" do
    let(:params) { {:action_url => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/action_url = "foo"/) }
  end

  context "Windows 2012 R2 with icon_image = /foo/bar" do
    let(:params) { {:icon_image => '/foo/bar', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/icon_image = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with icon_image = foo/bar (not a valid absolute path)" do
    let(:params) { {:icon_image => 'foo/bar', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with icon_image_alt => foo" do
    let(:params) { {:icon_image_alt => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'hostfoo',
                    :check_command => 'commandfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Service::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/icon_image_alt = "foo"/) }
  end
end
