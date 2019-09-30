require 'spec_helper'

describe 'systemd::tmpfiles' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('systemd::tmpfiles') }
        it { is_expected.to contain_exec('systemd-tmpfiles').with_command('systemd-tmpfiles --create') }
      end
    end
  end
end
