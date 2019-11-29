require 'spec_helper'

describe 'prometheus::snmp_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.6.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with all defaults' do
          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/etc/snmp-exporter.yaml').with(
              'ensure'  => 'present',
              'owner'   => 'root',
              'group'   => 'snmp-exporter',
              'mode'    => '0640',
              'content' => nil,
              'source'  => 'file:/opt/snmp_exporter-0.6.0.linux-amd64/snmp.yml',
              'require' => 'File[/opt/snmp_exporter-0.6.0.linux-amd64/snmp_exporter]',
              'notify'  => 'Service[snmp_exporter]'
            )
          }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_file('/usr/local/bin/snmp_exporter').with('target' => '/opt/snmp_exporter-0.6.0.linux-amd64/snmp_exporter') }
          it { is_expected.to contain_prometheus__daemon('snmp_exporter') }
          it { is_expected.to contain_user('snmp-exporter') }
          it { is_expected.to contain_group('snmp-exporter') }
          it { is_expected.to contain_service('snmp_exporter') }
          it { is_expected.to contain_archive('/tmp/snmp_exporter-0.6.0.tar.gz') }
          it { is_expected.to contain_file('/opt/snmp_exporter-0.6.0.linux-amd64/snmp_exporter') }
        end
      end
    end
  end
end
