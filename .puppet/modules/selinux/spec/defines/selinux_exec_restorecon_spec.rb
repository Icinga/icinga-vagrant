require 'spec_helper'

describe 'selinux::exec_restorecon' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with resource titled /opt/mycustompath' do
        let(:title) { '/opt/mycustompath' }

        context 'with defaults' do
          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').with(command: 'restorecon -R /opt/mycustompath', refreshonly: true) }
        end
        context 'without recursion' do
          let(:params) { { recurse: false } }

          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').with(command: 'restorecon /opt/mycustompath') }
        end
        context 'with force' do
          let(:params) { { force: true } }

          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').with(command: 'restorecon -F -R /opt/mycustompath') }
        end
        context 'with force, without recursion' do
          let(:params) { { force: true, recurse: false } }

          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').with(command: 'restorecon -F /opt/mycustompath') }
        end
        context 'ordering' do
          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').that_comes_before('Anchor[selinux::end]') }
          it { is_expected.to contain_anchor('selinux::module post').that_comes_before('Exec[selinux::exec_restorecon /opt/mycustompath]') }
        end
        context 'with optional parameters' do
          let(:params) { { onlyif: 'some_command', unless: 'some_other_command', refreshonly: false } }

          it do
            is_expected.to contain_exec('selinux::exec_restorecon /opt/mycustompath').with(
              onlyif: 'some_command',
              unless: 'some_other_command',
              refreshonly: false
            )
          end
        end
      end
      context 'with resource titled /opt/$HOME/some weird dir/' do
        let(:title) { '/opt/$HOME/some weird dir/' }

        context 'with defaults' do
          it { is_expected.to contain_exec('selinux::exec_restorecon /opt/$HOME/some weird dir/').with(command: "restorecon -R '/opt/$HOME/some weird dir/'", refreshonly: true) }
        end
      end
      context 'with path /weird/\'pa th\'/"quotes"' do
        let(:title) { 'just_for_testing' }
        let(:params) { { path: %q(/weird/'pa th'/"quotes") } }

        context 'with defaults' do
          it { is_expected.to contain_exec(%q(selinux::exec_restorecon /weird/'pa th'/"quotes")).with(command: %q(restorecon -R "/weird/'pa th'/\"quotes\""), refreshonly: true) }
        end
      end
    end
  end
end
