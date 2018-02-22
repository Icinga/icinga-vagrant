require 'spec_helper'

describe('icinga2::feature::compatlog', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::CompatLogger::compatlog')
        .with({ 'target' => '/etc/icinga2/features-available/compatlog.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::CompatLogger::compatlog')
        .with({ 'target' => '/etc/icinga2/features-available/compatlog.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
        .with({ 'target' => '/etc/icinga2/features-available/compatlog.conf' })
        .with_content(/rotation_method = "DAILY"/)
        .with_content(/log_dir = "\/var\/log\/icinga2\/compat"/) }
    end


    context "#{os} with rotation_method => HOURLY" do
      let(:params) { {:rotation_method => 'HOURLY'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
        .with({ 'target' => '/etc/icinga2/features-available/compatlog.conf' })
        .with_content(/rotation_method = "HOURLY"/) }
    end


    context "#{os} with rotation_method => foo (not a valid value)" do
      let(:params) { {:rotation_method => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with log_dir => /foo/bar" do
      let(:params) { {:log_dir => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
        .with({ 'target' => '/etc/icinga2/features-available/compatlog.conf' })
        .with_content(/log_dir = "\/foo\/bar"/) }
    end


    context "#{os} with log_dir => foo/bar (not an absolute path)" do
      let(:params) { {:log_dir => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end
  end
end


describe('icinga2::feature::compatlog', :type => :class) do
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

    it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::CompatLogger::compatlog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/compatlog.conf' })
                            .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::CompatLogger::compatlog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/compatlog.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('compatlog').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/compatlog.conf' })
                            .with_content(/rotation_method = "DAILY"/)
                            .with_content(/log_dir = "C:\/ProgramData\/icinga2\/var\/log\/icinga2\/compat"/) }
  end


  context 'Windows 2012 R2 with rotation_method => HOURLY' do
    let(:params) { {:rotation_method => 'HOURLY'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/compatlog.conf' })
                            .with_content(/rotation_method = "HOURLY"/) }
  end


  context 'Windows 2012 R2 with rotation_method => foo (not a valid value)' do
    let(:params) { {:rotation_method => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context 'Windows 2012 R2 with path => c:/foo/bar' do
    let(:params) { {:log_dir => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::CompatLogger::compatlog')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/compatlog.conf' })
                            .with_content(/log_dir = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with path => foo/bar (not an absolute path)' do
    let(:params) { {:log_dir => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end

end