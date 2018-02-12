require 'spec_helper'

describe 'selinux' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          selinux: true,
          selinux_config_mode: 'enforcing',
          selinux_config_policy: 'targeted',
          selinux_current_mode: 'enforcing'
        )
      end

      context 'config' do
        context 'invalid mode' do
          let(:params) { { mode: 'invalid' } }

          it { expect { is_expected.to create_class('selinux') }.to raise_error(Puppet::Error, %r{Enum}) }
        end

        context 'undef mode' do
          it { is_expected.to have_file_resource_count(5) }
          it { is_expected.to have_file_line_resource_count(0) }
          it { is_expected.to have_exec_resource_count(0) }
          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux') }
          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/bin') }
          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/bin/selinux_build_module_simple.sh') }
          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux/modules') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-enforcing') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-permissive') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-disabled') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-enforcing') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-permissive') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-disabled') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'enforcing' do
          let(:params) { { mode: 'enforcing' } }

          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux') }
          it { is_expected.to contain_file_line('set-selinux-config-to-enforcing').with(line: 'SELINUX=enforcing') }
          it { is_expected.to contain_exec('change-selinux-status-to-enforcing').with(command: 'setenforce 1') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'permissive' do
          let(:params) { { mode: 'permissive' } }

          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux') }
          it { is_expected.to contain_file_line('set-selinux-config-to-permissive').with(line: 'SELINUX=permissive') }
          it { is_expected.to contain_exec('change-selinux-status-to-permissive').with(command: 'setenforce 0') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'disabled' do
          let(:params) { { mode: 'disabled' } }

          it { is_expected.to contain_file('/var/lib/puppet/puppet-selinux') }
          it { is_expected.to contain_file_line('set-selinux-config-to-disabled').with(line: 'SELINUX=disabled') }
          it { is_expected.to contain_exec('change-selinux-status-to-disabled').with(command: 'setenforce 0') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'disabled to permissive creates autorelabel trigger file' do
          let(:facts) do
            hash = facts.merge(
              selinux: false
            )
            hash.delete(:selinux_config_mode)
            hash.delete(:selinux_current_mode)
            hash.delete(:selinux_config_policy)
            hash
          end
          let(:params) { { mode: 'permissive' } }

          it { is_expected.to contain_file('/.autorelabel').with(ensure: 'file') }
        end

        context 'disabled to enforcing creates autorelabel trigger file' do
          let(:facts) do
            hash = facts.merge(
              selinux: false
            )
            hash.delete(:selinux_config_mode)
            hash.delete(:selinux_current_mode)
            hash.delete(:selinux_config_policy)
            hash
          end
          let(:params) { { mode: 'enforcing' } }

          it { is_expected.to contain_file('/.autorelabel').with(ensure: 'file') }
        end
      end
    end
  end
end
