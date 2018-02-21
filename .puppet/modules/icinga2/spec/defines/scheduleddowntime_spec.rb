require 'spec_helper'

describe('icinga2::object::scheduleddowntime', :type => :define) do
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
          :target =>  '/bar/baz',
          :host_name => 'foohost',
          :author => 'fooauthor',
          :comment => 'foocomment',
          :ranges => { 'foo' => "bar", 'bar' => "foo"} } }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object ScheduledDowntime "bar"/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::ScheduledDowntime::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with scheduleddowntime_name => foo" do
      let(:params) { {:scheduleddowntime_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object ScheduledDowntime "foo"/) }
    end


    context "#{os} with host_name => foo" do
      let(:params) { {:host_name => 'foo', :target => '/bar/baz',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/host_name = "foo"/) }
    end


    context "#{os} with service_name => foo" do
      let(:params) { {:service_name => 'foo', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/service_name = "foo"/) }
    end


    context "#{os} with author => foo" do
      let(:params) { {:author => 'foo', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/author = "foo"/) }
    end


    context "#{os} with fixed => false" do
      let(:params) { {:fixed => false, :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/fixed = false/) }
    end


    context "#{os} with fixed => foo (not a valid boolean)" do
      let(:params) { {:fixed => 'foo', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with duration => 30" do
      let(:params) { {:duration => '30', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/duration = 30/) }
    end


    context "#{os} with duration => 30m" do
      let(:params) { {:duration => '30m', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/duration = 30m/) }
    end


    context "#{os} with duration => foo (not a valid integer)" do
      let(:params) { {:duration => 'foo', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment',
                      :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with ranges => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:ranges => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment' } }

      it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/ranges = {\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}/) }
    end


    context "#{os} with ranges => 'foo' (not a valid hash)" do
      let(:params) { {:ranges => 'foo', :target => '/bar/baz',
                      :host_name => 'foohost',
                      :author => 'fooauthor',
                      :comment => 'foocomment'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end
  end
end


describe('icinga2::object::scheduleddowntime', :type => :define) do
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
        :target =>  'C:/bar/baz',
        :host_name => 'foohost',
        :author => 'fooauthor',
        :comment => 'foocomment',
        :ranges => { 'foo' => "bar", 'bar' => "foo"} } }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object ScheduledDowntime "bar"/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::ScheduledDowntime::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with scheduleddowntime_name => foo" do
    let(:params) { {:scheduleddowntime_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object ScheduledDowntime "foo"/) }
  end


  context "Windows 2012 R2 with host_name => foo" do
    let(:params) { {:host_name => 'foo', :target => 'C:/bar/baz',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/host_name = "foo"/) }
  end


  context "Windows 2012 R2 with service_name => foo" do
    let(:params) { {:service_name => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/service_name = "foo"/) }
  end


  context "Windows 2012 R2 with author => foo" do
    let(:params) { {:author => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/author = "foo"/) }
  end


  context "Windows 2012 R2 with fixed => false" do
    let(:params) { {:fixed => false, :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/fixed = false/) }
  end


  context "Windows 2012 R2 with fixed => foo (not a valid boolean)" do
    let(:params) { {:fixed => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with duration => 30" do
    let(:params) { {:duration => '30', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/duration = 30/) }
  end


  context "Windows 2012 R2 with duration => 30m" do
    let(:params) { {:duration => '30m', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/duration = 30m/) }
  end


  context "Windows 2012 R2 with duration => foo (not a valid integer)" do
    let(:params) { {:duration => 'foo', :target => '/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment',
                    :ranges => { 'foo' => "bar", 'bar' => "foo"}} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with ranges => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:ranges => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment' } }

    it { is_expected.to contain_concat__fragment('icinga2::object::ScheduledDowntime::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/ranges = {\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}/) }
  end


  context "Windows 2012 R2 with ranges => 'foo' (not a valid hash)" do
    let(:params) { {:ranges => 'foo', :target => 'C:/bar/baz',
                    :host_name => 'foohost',
                    :author => 'fooauthor',
                    :comment => 'foocomment'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end
end
