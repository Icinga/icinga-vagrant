require 'spec_helper'

describe 'systemd::systemctl::daemon_reload' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('systemd::systemctl::daemon_reload') }
        it { is_expected.to create_exec('systemctl-daemon-reload') }
      end
    end
  end
end
