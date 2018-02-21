require 'spec_helper'

describe('icinga2::feature::graphite', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end


    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/host = "127.0.0.1"/)
        .with_content(/port = 2003/)
        .with_content(/host_name_template = "icinga2.\$host.name\$.host.\$host.check_command\$"/)
        .with_content(/service_name_template = "icinga2.\$host.name\$.services.\$service.name\$.\$service.check_command\$"/)
        .with_content(/enable_send_thresholds = false/)
        .with_content(/enable_send_metadata = false/) }
    end


    context "#{os} with host => foo.example.com" do
      let(:params) { {:host => 'foo.example.com'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/host = "foo.example.com"/) }
    end


    context "#{os} with port => 4247" do
      let(:params) { {:port => '4247'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/port = 4247/) }
    end


    context "#{os} with port => foo (not a valid integer)" do
      let(:params) { {:port => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with host_name_template => foo" do
      let(:params) { {:host_name_template => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/host_name_template = "foo"/) }
    end


    context "#{os} with service_name_template => foo" do
      let(:params) { {:service_name_template => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/service_name_template = "foo"/) }
    end


    context "#{os} with enable_send_thresholds => true" do
      let(:params) { {:enable_send_thresholds => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/enable_send_thresholds = true/) }
    end


    context "#{os} with enable_send_thresholds => false" do
      let(:params) { {:enable_send_thresholds => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/enable_send_thresholds = false/) }
    end


    context "#{os} with enable_send_thresholds => foo (not a valid boolean)" do
      let(:params) { {:enable_send_thresholds => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_send_metadata => true" do
      let(:params) { {:enable_send_metadata => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/enable_send_metadata = true/) }
    end


    context "#{os} with enable_send_metadata => false" do
      let(:params) { {:enable_send_metadata => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
        .with({ 'target' => '/etc/icinga2/features-available/graphite.conf' })
        .with_content(/enable_send_metadata = false/) }
    end


    context "#{os} with enable_send_metadata => foo (not a valid boolean)" do
      let(:params) { {:enable_send_metadata => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end
  end
end


describe('icinga2::feature::graphite', :type => :class) do
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

    it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('graphite').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/host = "127.0.0.1"/)
                            .with_content(/port = 2003/)
                            .with_content(/host_name_template = "icinga2.\$host.name\$.host.\$host.check_command\$"/)
                            .with_content(/service_name_template = "icinga2.\$host.name\$.services.\$service.name\$.\$service.check_command\$"/)
                            .with_content(/enable_send_thresholds = false/)
                            .with_content(/enable_send_metadata = false/) }
  end


  context "Windows 2012 R2 with host => foo.example.com" do
    let(:params) { {:host => 'foo.example.com'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/host = "foo.example.com"/) }
  end


  context "Windows 2012 R2 with port => 4247" do
    let(:params) { {:port => '4247'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/port = 4247/) }
  end


  context "Windows 2012 R2 with port => foo (not a valid integer)" do
    let(:params) { {:port => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with host_name_template => foo" do
    let(:params) { {:host_name_template => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/host_name_template = "foo"/) }
  end


  context "Windows 2012 R2 with service_name_template => foo" do
    let(:params) { {:service_name_template => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/service_name_template = "foo"/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => true" do
    let(:params) { {:enable_send_thresholds => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/enable_send_thresholds = true/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => false" do
    let(:params) { {:enable_send_thresholds => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/enable_send_thresholds = false/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => foo (not a valid boolean)" do
    let(:params) { {:enable_send_thresholds => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => true" do
    let(:params) { {:enable_send_metadata => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/enable_send_metadata = true/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => false" do
    let(:params) { {:enable_send_metadata => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::GraphiteWriter::graphite')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/graphite.conf' })
                            .with_content(/enable_send_metadata = false/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => foo (not a valid boolean)" do
    let(:params) { {:enable_send_metadata => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end
end
