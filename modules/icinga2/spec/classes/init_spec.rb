require 'spec_helper'

describe('icinga2', :type => :class) do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      case facts[:kernel]
      when 'Linux'
        before(:all) do
          @icinga2_conf = '/etc/icinga2/icinga2.conf'
          @constants_conf = '/etc/icinga2/constants.conf'
        end
      when 'FreeBSD'
        before(:all) do
          @icinga2_conf = '/usr/local/etc/icinga2/icinga2.conf'
          @constants_conf = '/usr/local/etc/icinga2/constants.conf'
        end
      end

      context 'with all default parameters' do
        it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }

        it { is_expected.to contain_service('icinga2').with({
          'ensure' => 'running',
          'enable' => true
          })
        }

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginDir = \"/usr/lib/nagios/plugins\"\n} }

          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginContribDir = \"/usr/lib/nagios/plugins\"\n} }

          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const ManubulonPluginDir = \"/usr/lib/nagios/plugins\"\n} }
        when 'RedHat'
          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginDir = \"/usr/lib64/nagios/plugins\"\n} }

          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginContribDir = \"/usr/lib64/nagios/plugins\"\n} }

          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const ManubulonPluginDir = \"/usr/lib64/nagios/plugins\"\n} }
        when 'Suse'
          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginDir = \"/usr/lib/nagios/plugins\"\n} }
          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const PluginContribDir = \"/usr/lib/nagios/plugins\"\n} }
          it { is_expected.to contain_file(@constants_conf)
            .with_content %r{^const ManubulonPluginDir = \"/usr/lib/nagios/plugins\"\n} }
        end

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const NodeName = \".+\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const ZoneName = \".+\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const TicketSalt = \"\"\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^// managed by puppet\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^include <plugins>\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^include <plugins-contrib>\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^include <windows-plugins>\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^include <nscp>\n} }

        it { is_expected.to contain_file(@icinga2_conf)
          .with_content %r{^include_recursive \"conf.d\"\n} }

        it { is_expected.to contain_icinga2__feature('checker')
          .with({'ensure' => 'present'}) }

        it { is_expected.to contain_icinga2__feature('mainlog')
          .with({'ensure' => 'present'}) }

        it { is_expected.to contain_icinga2__feature('notification')
          .with({'ensure' => 'present'}) }

        case facts[:osfamily]
        when 'Debian'
          it { should_not contain_apt__source('icinga-stable-release') }
        when 'RedHat'
          it { should_not contain_yumrepo('icinga-stable-release') }
        when 'Suse'
          it { should_not contain_zypprepo('icinga-stable-release') }
        end

        context "#{os} with manage_package => false" do
          let(:params) { {:manage_package => false} }

          it { should_not contain_package('icinga2').with({ 'ensure' => 'installed' }) }
        end
      end
    end
  end
end

describe('icinga2', :type => :class) do
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

  before(:all) do
    @icinga2_conf = "C:/ProgramData/icinga2/etc/icinga2/icinga2.conf"
    @constants_conf = "C:/ProgramData/icinga2/etc/icinga2/constants.conf"
  end

  context 'Windows 2012 R2 with all default parameters' do

    it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }

    it { is_expected.to contain_service('icinga2').with({
                                                            'ensure' => 'running',
                                                            'enable' => true
                                                        })
    }


    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const PluginDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const PluginContribDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const ManubulonPluginDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const NodeName = \".+\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const ZoneName = \".+\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^const TicketSalt = \"\"\r\n} }

    it { is_expected.to contain_file(@constants_conf)
                            .with_content %r{^} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^// managed by puppet\r\n} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^include <plugins>\r\n} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^include <plugins-contrib>\r\n} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^include <windows-plugins>\r\n} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^include <nscp>\r\n} }

    it { is_expected.to contain_file(@icinga2_conf)
                            .with_content %r{^include_recursive \"conf.d\"\r\n} }

    it { is_expected.to contain_icinga2__feature('checker')
                            .with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__feature('mainlog')
                            .with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__feature('notification')
                            .with({'ensure' => 'present'}) }
  end

  context "Windows 2012 R2 with manage_package => false" do
    let(:params) { {:manage_package => false} }

    it { should_not contain_package('icinga2').with({ 'ensure' => 'installed' }) }
  end
end

describe('icinga2', :type => :class) do
  let(:facts) { {
      :kernel => 'foo',
      :osfamily => 'bar',
  } }

  context 'on unsupported plattform' do
    it { is_expected.to raise_error(Puppet::Error, /bar is not supported/) }
  end
end
