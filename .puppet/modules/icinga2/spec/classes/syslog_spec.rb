require 'spec_helper'

describe('icinga2::feature::syslog', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::SyslogLogger::syslog')
        .with({ 'target' => '/etc/icinga2/features-available/syslog.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::SyslogLogger::syslog')
        .with({ 'target' => '/etc/icinga2/features-available/syslog.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::SyslogLogger::syslog')
        .with({ 'target' => '/etc/icinga2/features-available/syslog.conf' })
        .with_content(/severity = "warning"/) }
    end


    context "#{os} with severity => notice" do
      let(:params) { {:severity => 'notice'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::SyslogLogger::syslog')
        .with({ 'target' => '/etc/icinga2/features-available/syslog.conf' })
        .with_content(/severity = "notice"/) }
    end


    context "#{os} with severity => foo (not a valid value)" do
      let(:params) { {:severity => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end
  end


end

describe('icinga2::feature::syslog', :type => :class) do
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

    it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::SyslogLogger::syslog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/syslog.conf' })
                            .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::SyslogLogger::syslog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/syslog.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('syslog').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::SyslogLogger::syslog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/syslog.conf' })
                            .with_content(/severity = "warning"/) }
  end


  context 'Windows 2012 R2 with severity => notice' do
    let(:params) { {:severity => 'notice'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::SyslogLogger::syslog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/syslog.conf' })
                            .with_content(/severity = "notice"/) }
  end


  context 'Windows 2012 R2 with severity => foo (not a valid value)' do
    let(:params) { {:severity => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end
end