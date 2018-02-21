require 'spec_helper'

describe('icinga2::object::eventcommand', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {:target =>  '/bar/baz', :command => ['foocommand']} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object EventCommand "bar"/)
                              .with_content(/command = \[ "foocommand", \]/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::EventCommand::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with command => [ PluginDir + /bar, foo ]" do
      let(:params) { {:command => [ 'PluginDir + /bar', 'foo' ], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
        .with({'target' => '/bar/baz'})
        .with_content(/command = \[ PluginDir \+ "\/bar", "foo", \]/) }
    end


    context "#{os} with eventcommand_name => foo" do
      let(:params) { {:eventcommand_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object EventCommand "foo"/) }
    end


    context "#{os} with command => [foo, bar]" do
      let(:params) { {:command => ['foo','bar'], :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/command = \[ "foo", "bar", \]/) }
    end


    context "#{os} with env => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:env => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz', :command => ['foocommand'] } }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/env = {\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}/) }
    end


    context "#{os} with env => 'foo' (not a valid hash)" do
      let(:params) { {:env => 'foo', :target => '/bar/baz', :command => ['foocommand']} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with vars => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => '/bar/baz', :command => ['foocommand'] } }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/vars.foo = "bar"/)
                              .with_content(/vars.bar = "foo"/) }
    end


    context "#{os} with timeout => 30" do
      let(:params) { {:timeout => '30', :target => '/bar/baz', :command => ['foocommand']} }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/timeout = 30/) }
    end


    context "#{os} with timeout => foo (not a valid integer)" do
      let(:params) { {:timeout => 'foo', :target => '/bar/baz', :command => ['foocommand']} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with arguments => {-foo1 => bar1, -foo2 => {bar_21 => baz21}}" do
      let(:params) { {
          :arguments => {'-foo1' => 'bar1', '-foo2' => {'bar_21' => 'baz21'}},
          :target => '/bar/baz',
          :command => ['foocommand']} }

      it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/arguments = {\n\s*"-foo1" = "bar1"\n\s*"-foo2" = {\n\s*bar_21 = "baz21"\n\s*}\n\s*}/) }
    end


    context "#{os} with arguments => foo (not a valid hash)" do
      let(:params) { {:arguments => 'foo', :target => '/bar/baz', :command => ['foocommand']} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end
  end
end


describe('icinga2::object::eventcommand', :type => :define) do
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
    let(:params) { {:target =>  'C:/bar/baz', :command => ['foocommand']} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object EventCommand "bar"/)
                            .with_content(/command = \[ "foocommand", \]/) }


    it { is_expected.to contain_icinga2__object('icinga2::object::EventCommand::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with command => [ PluginDir + /bar, foo ]" do
    let(:params) { {:command => [ 'PluginDir + /bar', 'foo' ], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
      .with({'target' => 'C:/bar/baz'})
      .with_content(/command = \[ PluginDir \+ "\/bar", "foo", \]/) }
  end


  context "Windows 2012 R2 with eventcommand_name => foo" do
    let(:params) { {:eventcommand_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object EventCommand "foo"/) }
  end


  context "Windows 2012 R2 with command => [foo, bar]" do
    let(:params) { {:command => ['foo','bar'], :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/command = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with env => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:env => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz', :command => ['foocommand'] } }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/env = {\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}/) }
  end


  context "Windows 2012 R2 with env => 'foo' (not a valid hash)" do
    let(:params) { {:env => 'foo', :target => 'C:/bar/baz', :command => ['foocommand']} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with vars => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:vars => { 'foo' => "bar", 'bar' => "foo"}, :target => 'C:/bar/baz', :command => ['foocommand'] } }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/vars.foo = "bar"/)
                            .with_content(/vars.bar = "foo"/) }
  end


  context "Windows 2012 R2 with timeout => 30" do
    let(:params) { {:timeout => '30', :target => 'C:/bar/baz', :command => ['foocommand']} }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/timeout = 30/) }
  end


  context "Windows 2012 R2 with timeout => foo (not a valid integer)" do
    let(:params) { {:timeout => 'foo', :target => 'C:/bar/baz', :command => ['foocommand']} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with arguments => {-foo1 => bar1, -foo2 => {bar_21 => baz21}}" do
    let(:params) { {:arguments => {'-foo1' => 'bar1', '-foo2' => {'bar_21' => 'baz21'}},
                    :target => 'C:/bar/baz',
                    :command => ['foocommand']} }

    it { is_expected.to contain_concat__fragment('icinga2::object::EventCommand::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/arguments = {\r\n\s*"-foo1" = "bar1"\r\n\s*"-foo2" = {\r\n\s*bar_21 = "baz21"\r\n\s*}\r\n\s*}/) }
  end


  context "Windows 2012 R2 with arguments => foo (not a valid hash)" do
    let(:params) { {:arguments => 'foo', :target => 'C:/bar/baz', :command => ['foocommand']} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end

end
