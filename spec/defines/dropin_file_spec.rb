require 'spec_helper'

describe 'systemd::dropin_file' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        let(:title) { 'test.conf' }

        let(:params) {{
          :unit    => 'test.service',
          :content => 'random stuff'
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d").with(
          :ensure  => 'directory',
          :recurse => 'true',
          :purge   => 'true'
        ) }

        it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d/#{title}").with(
          :ensure  => 'file',
          :content => /#{params[:content]}/,
          :mode    => '0444'
        ) }

        context 'with daemon_reload => lazy (default)' do
          it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d/#{title}").that_notifies('Class[systemd::systemctl::daemon_reload]') }

          it { is_expected.not_to create_exec("#{params[:unit]}-systemctl-daemon-reload") }
        end

        context 'with daemon_reload => eager' do
          let(:params) do
            super().merge({ :daemon_reload => 'eager' })
          end

          it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d/#{title}").that_notifies("Exec[#{params[:unit]}-systemctl-daemon-reload]") }

          it { is_expected.to create_exec("#{params[:unit]}-systemctl-daemon-reload") }
        end

        context 'with a bad unit type' do
          let(:title) { 'test.badtype' }

          it {
            expect{
              is_expected.to compile.with_all_deps
            }.to raise_error(/expects a match for Systemd::Dropin/)
          }
        end

        context 'with another drop-in file with the same filename (and content)' do
          let(:default_params) {{
            :filename => 'longer-timeout.conf',
            :content  => 'random stuff'
          }}
          # Create drop-in file longer-timeout.conf for unit httpd.service
          let :pre_condition do
            "systemd::dropin_file { 'httpd_longer-timeout':
              filename => '#{default_params[:filename]}',
              unit     => 'httpd.service',
              content  => '#{default_params[:context]}',
            }"
          end
          #
          # Create drop-in file longer-timeout.conf for unit ftp.service
          let (:title) {'ftp_longer-timeout'}
          let :params do
            default_params.merge({
              :unit     => 'ftp.service'
            })
          end

          it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d/#{params[:filename]}").with(
            :ensure  => 'file',
            :content => /#{params[:content]}/,
            :mode    => '0444'
          ) }
        end
        context 'with sensitve content' do
          let(:title) { 'sensitive.conf' }
          let(:params) {{
            :unit    => 'sensitive.service',
            :content     => RSpec::Puppet::RawString.new("Sensitive('TEST_CONTENT')")
          }}

          it { is_expected.to create_file("/etc/systemd/system/#{params[:unit]}.d/#{title}").with(
            :ensure  => 'file',
            :content => 'TEST_CONTENT'
          ) }

        end
      end
    end
  end
end
