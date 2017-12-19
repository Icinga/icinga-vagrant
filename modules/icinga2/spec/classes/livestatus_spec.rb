require 'spec_helper'

describe('icinga2::feature::livestatus', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/socket_type = "unix"/)
        .with_content(/bind_host = "127.0.0.1"/)
        .with_content(/bind_port = 6558/)
        .with_content(/socket_path = "\/var\/run\/icinga2\/cmd\/livestatus"/)
        .with_content(/compat_log_path = "\/var\/log\/icinga2\/compat"/) }
    end


    context "#{os} with socket_type => tcp" do
      let(:params) { {:socket_type => 'tcp'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/socket_type = "tcp"/) }
    end


    context "#{os} with socket_type => foo (not a valid value)" do
      let(:params) { {:socket_type => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported. Valid values are 'unix' and 'tcp'./) }
    end


    context "#{os} with bind_host => foo.example.com" do
      let(:params) { {:bind_host => 'foo.example.com'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/bind_host = "foo.example.com"/) }
    end


    context "#{os} with bind_port => 4247" do
      let(:params) { {:bind_port => '4247'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/bind_port = 4247/) }
    end


    context "#{os} with bind_port => foo (not a valid integer)" do
      let(:params) { {:bind_port => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with socket_path => /foo/bar" do
      let(:params) { {:socket_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/socket_path = "\/foo\/bar"/) }
    end


    context "#{os} with socket_path => foo/bar (not an absolute path)" do
      let(:params) { {:socket_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with compat_log_path => /foo/bar" do
      let(:params) { {:compat_log_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
        .with({ 'target' => '/etc/icinga2/features-available/livestatus.conf' })
        .with_content(/compat_log_path = "\/foo\/bar"/) }
    end


    context "#{os} with compat_log_path => foo/bar (not an absolute path)" do
      let(:params) { {:compat_log_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end
  end
end

describe('icinga2::feature::livestatus', :type => :class) do
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

  let(:pre_condition) { [
      "class { 'icinga2': features => [], }"
  ] }

  context 'Windows 2012 R2 with ensure => present' do
    let(:params) { {:ensure => 'present'} }

    it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('livestatus').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/socket_type = "unix"/)
                            .with_content(/bind_host = "127.0.0.1"/)
                            .with_content(/bind_port = 6558/)
                            .with_content(/socket_path = "C:\/ProgramData\/icinga2\/var\/run\/icinga2\/cmd\/livestatus"/)
                            .with_content(/compat_log_path = "C:\/ProgramData\/icinga2\/var\/log\/icinga2\/compat"/) }
  end


  context 'Windows 2012 R2 with socket_type => tcp' do
    let(:params) { {:socket_type => 'tcp'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/socket_type = "tcp"/) }
  end


  context 'Windows 2012 R2 with socket_type => foo (not a valid value)' do
    let(:params) { {:socket_type => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported. Valid values are 'unix' and 'tcp'./) }
  end


  context "Windows 2012 R2 with bind_host => foo.example.com" do
    let(:params) { {:bind_host => 'foo.example.com'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/bind_host = "foo.example.com"/) }
  end


  context "Windows 2012 R2 with bind_port => 4247" do
    let(:params) { {:bind_port => '4247'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/bind_port = 4247/) }
  end


  context "Windows 2012 R2 with bind_port => foo (not a valid integer)" do
    let(:params) { {:bind_port => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context 'Windows 2012 R2 with socket_path => c:/foo/bar' do
    let(:params) { {:socket_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/socket_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with socket_path => foo/bar (not an absolute path)' do
    let(:params) { {:socket_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context 'Windows 2012 R2 with compat_log_path => c:/foo/bar' do
    let(:params) { {:compat_log_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::LivestatusListener::livestatus')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/livestatus.conf' })
                            .with_content(/compat_log_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with compat_log_path => foo/bar (not an absolute path)' do
    let(:params) { {:compat_log_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end
end
