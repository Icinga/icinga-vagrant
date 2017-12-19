require 'spec_helper'

describe('icinga2::feature::perfdata', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/rotation_interval = 30s/)
        .with_content(/host_perfdata_path = "\/var\/spool\/icinga2\/perfdata\/host-perfdata"/)
        .with_content(/service_perfdata_path = "\/var\/spool\/icinga2\/perfdata\/service-perfdata"/)
        .with_content(/host_temp_path = "\/var\/spool\/icinga2\/tmp\/host-perfdata"/)
        .with_content(/service_temp_path = "\/var\/spool\/icinga2\/tmp\/service-perfdata"/) }
    end


    context "#{os} with rotation_interval => 1m" do
      let(:params) { {:rotation_interval => '1m'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/rotation_interval = 1m/) }
    end


    context "#{os} with rotation_interval => foo (not a valid value)" do
      let(:params) { {:rotation_interval => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with host_perfdata_path => /foo/bar" do
      let(:params) { {:host_perfdata_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/host_perfdata_path = "\/foo\/bar"/) }
    end


    context "#{os} with host_perfdata_path => foo/bar (not an absolute path)" do
      let(:params) { {:host_perfdata_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with service_perfdata_path => /foo/bar" do
      let(:params) { {:service_perfdata_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/service_perfdata_path = "\/foo\/bar"/) }
    end


    context "#{os} with service_perfdata_path => foo/bar (not an absolute path)" do
      let(:params) { {:service_perfdata_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with host_temp_path => /foo/bar" do
      let(:params) { {:host_temp_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/host_temp_path = "\/foo\/bar"/) }
    end


    context "#{os} with host_temp_path => foo/bar (not an absolute path)" do
      let(:params) { {:host_temp_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with service_temp_path => /foo/bar" do
      let(:params) { {:service_temp_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/service_temp_path = "\/foo\/bar"/) }
    end


    context "#{os} with service_temp_path => foo/bar (not an absolute path)" do
      let(:params) { {:service_temp_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with host_format_template => foo" do
      let(:params) { {:host_format_template => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/host_format_template = "foo"/) }
    end

    context "#{os} with service_format_template => foo" do
      let(:params) { {:service_format_template => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
        .with({ 'target' => '/etc/icinga2/features-available/perfdata.conf' })
        .with_content(/service_format_template = "foo"/) }
    end


  end
end

describe('icinga2::feature::perfdata', :type => :class) do
  let(:pre_condition) { [
      "class { 'icinga2': features => [], }"
  ] }

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


  context 'Windows 2012 R2 with ensure => present' do
    let(:params) { {:ensure => 'present'} }

    it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('perfdata').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/rotation_interval = 30s/)
      .with_content(/host_perfdata_path = "C:\/ProgramData\/icinga2\/var\/spool\/icinga2\/perfdata\/host-perfdata"/)
      .with_content(/service_perfdata_path = "C:\/ProgramData\/icinga2\/var\/spool\/icinga2\/perfdata\/service-perfdata"/)
      .with_content(/host_temp_path = "C:\/ProgramData\/icinga2\/var\/spool\/icinga2\/tmp\/host-perfdata"/)
      .with_content(/service_temp_path = "C:\/ProgramData\/icinga2\/var\/spool\/icinga2\/tmp\/service-perfdata"/) }
  end


  context 'Windows 2012 R2 with rotation_interval => 1m' do
    let(:params) { {:rotation_interval => '1m'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/rotation_interval = 1m/) }
  end


  context 'Windows 2012 R2 with rotation_interval => foo (not a valid value)' do
    let(:params) { {:rotation_interval => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context 'Windows 2012 R2 with host_perfdata_path => c:/foo/bar' do
    let(:params) { {:host_perfdata_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/host_perfdata_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with host_perfdata_path => foo/bar (not an absolute path)' do
    let(:params) { {:host_perfdata_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context 'Windows 2012 R2 with service_perfdata_path => c:/foo/bar' do
    let(:params) { {:service_perfdata_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/service_perfdata_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with service_perfdata_path => foo/bar (not an absolute path)' do
    let(:params) { {:service_perfdata_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context 'Windows 2012 R2 with host_temp_path => c:/foo/bar' do
    let(:params) { {:host_temp_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/host_temp_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with host_temp_path => foo/bar (not an absolute path)' do
    let(:params) { {:host_temp_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context 'Windows 2012 R2 with service_temp_path => c:/foo/bar' do
    let(:params) { {:service_temp_path => 'c:/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/service_temp_path = "c:\/foo\/bar"/) }
  end


  context 'Windows 2012 R2 with service_temp_path => foo/bar (not an absolute path)' do
    let(:params) { {:service_temp_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with host_format_template => foo" do
    let(:params) { {:host_format_template => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/host_format_template = "foo"/) }
  end

  context "Windows 2012 R2 with service_format_template => foo" do
    let(:params) { {:service_format_template => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::PerfdataWriter::perfdata')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/perfdata.conf' })
      .with_content(/service_format_template = "foo"/) }
  end


end
