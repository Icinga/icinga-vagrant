require 'spec_helper'

describe 'systemd::tmpfile' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        let(:title) { 'random_tmpfile' }

        let(:params) {{
          :content => 'random stuff'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file("/etc/tmpfiles.d/#{title}").with(
          :ensure  => 'file',
          :content => /#{params[:content]}/,
          :mode    => '0444'
        ) }
      end
    end
  end
end
