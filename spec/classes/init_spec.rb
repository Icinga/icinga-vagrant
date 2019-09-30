require 'spec_helper'

describe 'systemd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('systemd') }
        it { is_expected.to create_class('systemd::systemctl::daemon_reload') }
        it { is_expected.to contain_class('systemd::journald')}
        it { is_expected.to create_service('systemd-journald') }
        it { is_expected.to have_ini_setting_resource_count(0) }
        it { is_expected.to_not create_service('systemd-resolved') }
        it { is_expected.to_not create_service('systemd-networkd') }
        it { is_expected.to_not create_service('systemd-timesyncd') }

        context 'when enabling resolved and networkd' do
          let(:params) {{
            :manage_resolved => true,
            :manage_networkd => true
          }}

          it { is_expected.to create_service('systemd-resolved').with_ensure('running') }
          it { is_expected.to create_service('systemd-resolved').with_enable(true) }
          it { is_expected.to create_service('systemd-networkd').with_ensure('running') }
          it { is_expected.to create_service('systemd-networkd').with_enable(true) }
        end

        context 'when enabling resolved with DNS values (string)' do
          let(:params) {{
            :manage_resolved => true,
            :dns => '8.8.8.8 8.8.4.4',
            :fallback_dns => '2001:4860:4860::8888 2001:4860:4860::8844',
          }}

          it { is_expected.to create_service('systemd-resolved').with_ensure('running') }
          it { is_expected.to create_service('systemd-resolved').with_enable(true) }
          it { is_expected.to contain_ini_setting('dns')}
          it { is_expected.to contain_ini_setting('fallback_dns')}
          it { is_expected.not_to contain_ini_setting('domains')}
          it { is_expected.not_to contain_ini_setting('multicast_dns')}
          it { is_expected.not_to contain_ini_setting('llmnr')}
          it { is_expected.not_to contain_ini_setting('dnssec')}
          it { is_expected.not_to contain_ini_setting('dnsovertls')}
          it { is_expected.not_to contain_ini_setting('cache')}
          it { is_expected.not_to contain_ini_setting('dns_stub_listener')}
        end

        context 'when enabling resolved with DNS values (array)' do
          let(:params) {{
            :manage_resolved => true,
            :dns => %w(8.8.8.8 8.8.4.4),
            :fallback_dns => %w(2001:4860:4860::8888 2001:4860:4860::8844),
          }}

          it { is_expected.to create_service('systemd-resolved').with_ensure('running') }
          it { is_expected.to create_service('systemd-resolved').with_enable(true) }
          it { is_expected.to contain_ini_setting('dns')}
          it { is_expected.to contain_ini_setting('fallback_dns')}
          it { is_expected.not_to contain_ini_setting('domains')}
          it { is_expected.not_to contain_ini_setting('multicast_dns')}
          it { is_expected.not_to contain_ini_setting('llmnr')}
          it { is_expected.not_to contain_ini_setting('dnssec')}
          it { is_expected.not_to contain_ini_setting('dnsovertls')}
          it { is_expected.not_to contain_ini_setting('cache')}
          it { is_expected.not_to contain_ini_setting('dns_stub_listener')}
        end

        context 'when enabling resolved with DNS values (full)' do
          let(:params) {{
            :manage_resolved => true,
            :dns => %w(8.8.8.8 8.8.4.4),
            :fallback_dns => %w(2001:4860:4860::8888 2001:4860:4860::8844),
            :domains => %w(2001:4860:4860::8888 2001:4860:4860::8844),
            :llmnr => true,
            :multicast_dns => false,
            :dnssec => false,
            :dnsovertls => 'no',
            :cache => true,
            :dns_stub_listener => 'udp',
          }}

          it { is_expected.to create_service('systemd-resolved').with_ensure('running') }
          it { is_expected.to create_service('systemd-resolved').with_enable(true) }
          it { is_expected.to contain_ini_setting('dns')}
          it { is_expected.to contain_ini_setting('fallback_dns')}
          it { is_expected.to contain_ini_setting('domains')}
          it { is_expected.to contain_ini_setting('multicast_dns')}
          it { is_expected.to contain_ini_setting('llmnr')}
          it { is_expected.to contain_ini_setting('dnssec')}
          it { is_expected.to contain_ini_setting('dnsovertls')}
          it { is_expected.to contain_ini_setting('cache')}
          it { is_expected.to contain_ini_setting('dns_stub_listener')}
        end

        context 'when enabling timesyncd' do
          let(:params) {{
            :manage_timesyncd => true
          }}

          it { is_expected.to create_service('systemd-timesyncd').with_ensure('running') }
          it { is_expected.to create_service('systemd-timesyncd').with_enable(true) }
          it { is_expected.not_to create_service('systemd-resolved').with_ensure('running') }
          it { is_expected.not_to create_service('systemd-resolved').with_enable(true) }
          it { is_expected.not_to create_service('systemd-networkd').with_ensure('running') }
          it { is_expected.not_to create_service('systemd-networkd').with_enable(true) }
        end

        context 'when enabling timesyncd with NTP values (string)' do
          let(:params) {{
            :manage_timesyncd => true,
            :ntp_server => '0.pool.ntp.org 1.pool.ntp.org',
            :fallback_ntp_server => '2.pool.ntp.org 3.pool.ntp.org'
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('ntp_server')}
          it { is_expected.to contain_ini_setting('fallback_ntp_server')}
        end

        context 'when enabling timesyncd with NTP values (array)' do
          let(:params) {{
            :manage_timesyncd => true,
            :ntp_server => %w(0.pool.ntp.org 1.pool.ntp.org),
            :fallback_ntp_server => %w(2.pool.ntp.org 3.pool.ntp.org)
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('ntp_server')}
          it { is_expected.to contain_ini_setting('fallback_ntp_server')}
        end

        context 'when passing service limits' do
          let(:params) {{
            :service_limits => {'openstack-nova-compute.service' => {'limits' => {'LimitNOFILE' => 32768}}}
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_systemd__service_limits('openstack-nova-compute.service').with_limits({'LimitNOFILE' => 32768}) }
        end

        context 'when managing Accounting options' do
          let :params do
            {
              manage_accounting: true,
            }
          end

          it { is_expected.to contain_class('systemd::system')}

          case facts[:os]['family']
          when 'Archlinux'
            accounting = ['DefaultCPUAccounting', 'DefaultIOAccounting', 'DefaultIPAccounting', 'DefaultBlockIOAccounting', 'DefaultMemoryAccounting', 'DefaultTasksAccounting']
          when 'Debian'
            accounting = ['DefaultCPUAccounting', 'DefaultBlockIOAccounting', 'DefaultMemoryAccounting']
          when 'RedHat'
            accounting = ['DefaultCPUAccounting', 'DefaultBlockIOAccounting', 'DefaultMemoryAccounting', 'DefaultTasksAccounting']
          end
          accounting.each do |account|
            it { is_expected.to contain_ini_setting(account)}
          end
          it { is_expected.to compile.with_all_deps }
        end
        context 'when enabling journald with options' do
          let(:params) do
            {
              :manage_journald   => true,
              :journald_settings => {
                'Storage'         => 'auto',
                'MaxRetentionSec' => '5day',
                'MaxLevelStore'   => {
                  'ensure' => 'absent',
                },
              }
            }
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_service('systemd-journald').with(
            :ensure => 'running'
          ) }
          it { is_expected.to have_ini_setting_resource_count(3) }
          it { is_expected.to contain_ini_setting('Storage').with(
            :path    => '/etc/systemd/journald.conf',
            :section => 'Journal',
            :notify  => 'Service[systemd-journald]',
            :value   => 'auto',
          )}
          it { is_expected.to contain_ini_setting('MaxRetentionSec').with(
            :path    => '/etc/systemd/journald.conf',
            :section => 'Journal',
            :notify  => 'Service[systemd-journald]',
            :value   => '5day',
          )}
          it { is_expected.to contain_ini_setting('MaxLevelStore').with(
            :path    => '/etc/systemd/journald.conf',
            :section => 'Journal',
            :notify  => 'Service[systemd-journald]',
            :ensure  => 'absent',
          )}
        end

        context 'when disabling journald' do
          let(:params) do
            {
              :manage_journald => false,
            }
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_service('systemd-journald') }
        end
      end
    end
  end
end
