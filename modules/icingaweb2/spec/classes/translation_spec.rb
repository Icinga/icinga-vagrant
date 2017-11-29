require 'spec_helper'

describe('icingaweb2::module::translation', :type => :class) do
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "with ensure present" do
        let(:params) { { :ensure => 'present', } }

        it { is_expected.to contain_icingaweb2__module('translation')
          .with_ensure('present')
          .with_install_method('none')
          .with_module_dir('/usr/share/icingaweb2/modules/translation')
          .with_settings({ 'module-translation'=>{
                                 'section_name' => 'translation',
                                 'target'=>'/etc/icingaweb2/modules/translation/config.ini',
                                 'settings'=>{
                                   'msgmerge' => '/usr/bin/msgmerge',
                                   'xgettext' => '/usr/bin/xgettext',
                                   'msgfmt'   => '/usr/bin/msgfmt',
                                 }
                             }
                         }) }

        case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_package('gettext').with({ 'ensure' => 'present' }) }
          when 'RedHat'
            it { is_expected.to contain_package('gettext').with({ 'ensure' => 'present' }) }
          when 'Suse'
            it { is_expected.to contain_package('gettext-tools').with({ 'ensure' => 'present' }) }
        end
      end

      context "with ensure absent" do
        let(:params) { { :ensure => 'absent', } }

        it { is_expected.to contain_icingaweb2__module('translation')
          .with_ensure('absent')
          .with_install_method('none')
          .with_module_dir('/usr/share/icingaweb2/modules/translation')
                         }

        case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_package('gettext').with({ 'ensure' => 'absent' }) }
          when 'RedHat'
            it { is_expected.to contain_package('gettext').with({ 'ensure' => 'absent' }) }
          when 'Suse'
            it { is_expected.to contain_package('gettext-tools').with({ 'ensure' => 'absent' }) }
        end
      end

      context "with ensure foobar" do
        let(:params) { { :ensure => 'foobar' } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['absent', 'present'\]/) }
      end
    end
  end
end
