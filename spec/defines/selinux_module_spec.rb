require 'spec_helper'

describe 'selinux::module' do
  let(:title) { 'mymodule' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'present case' do
        let(:params) do
          {
            source: 'puppet:///modules/mymodule/selinux/mymodule.te'
          }
        end

        it do
          is_expected.to contain_file('/usr/share/selinux/mymodule.te').that_notifies('Exec[/usr/share/selinux/mymodule.pp]')
          is_expected.to contain_exec('/usr/share/selinux/mymodule.pp').with(command: 'make -f /usr/share/selinux/devel/Makefile mymodule.pp')
          is_expected.to contain_selmodule('mymodule').with_ensure('present')
        end
      end

      context 'present case and prefix set' do
        let(:params) do
          {
            source: 'puppet:///modules/mymodule/selinux/mymodule.te',
            prefix: 'local_'
          }
        end

        it do
          is_expected.to contain_file('/usr/share/selinux/local_mymodule.te').that_notifies('Exec[/usr/share/selinux/local_mymodule.pp]')
          is_expected.to contain_exec('/usr/share/selinux/local_mymodule.pp').with(command: 'make -f /usr/share/selinux/devel/Makefile local_mymodule.pp')
          is_expected.to contain_selmodule('mymodule').with_ensure('present')
        end
      end

      context 'absent case' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it do
          is_expected.to contain_selmodule('mymodule').with_ensure('absent')
        end
      end
    end
  end
end
