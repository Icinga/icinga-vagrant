require 'spec_helper'

describe 'prometheus::node_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_prometheus__daemon('node_exporter').with(options: '  ') }
        it { is_expected.to contain_service('node_exporter') }

        if facts[:os]['name'] == 'Archlinux'
          it { is_expected.not_to contain_user('node-exporter') }
          it { is_expected.not_to contain_group('node-exporter') }
          it { is_expected.not_to contain_file('/opt/node_exporter-0.18.1.linux-amd64/node_exporter') }
          it { is_expected.not_to contain_file('/usr/local/bin/node_exporter') }
          it { is_expected.to contain_package('prometheus-node-exporter') }
          it { is_expected.to contain_file('/etc/default/node_exporter') }
          it { is_expected.to contain_systemd__unit_file('node_exporter.service') }
        else
          it { is_expected.to contain_user('node-exporter') }
          it { is_expected.to contain_group('node-exporter') }
          it { is_expected.to contain_file('/opt/node_exporter-0.18.1.linux-amd64/node_exporter') }
          it { is_expected.to contain_file('/usr/local/bin/node_exporter') }
        end

        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i < 7
          it { is_expected.to contain_file('/etc/sysconfig/node_exporter') }
          it { is_expected.to contain_file('/etc/init.d/node_exporter') }
        end

        if facts[:os]['release']['major'].to_i == 14
          it { is_expected.to contain_file('/etc/init/node_exporter.conf') }
        end
      end

      context 'without collector parameters' do
        let(:params) do
          {
            collectors_enable: %w[foo bar],
            collectors_disable: %w[baz qux],
            install_method: 'url'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/node_exporter-0.18.1.tar.gz') }
        it { is_expected.to contain_prometheus__daemon('node_exporter').with(options: ' --collector.foo --collector.bar --no-collector.baz --no-collector.qux') }
        if facts[:os]['name'] == 'Archlinux'
          it { is_expected.to contain_file('/usr/bin/node_exporter') }
          it { is_expected.not_to contain_file('/usr/local/bin/node_exporter') }
        else
          it { is_expected.to contain_file('/usr/local/bin/node_exporter') }
          it { is_expected.not_to contain_file('/usr/bin/node_exporter') }
        end
      end

      context 'without collector parameters and extra options' do
        let(:params) do
          {
            collectors_enable: %w[foo bar],
            collectors_disable: %w[baz qux],
            extra_options: '--path.procfs /host/proc --path.sysfs /host/sys'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_prometheus__daemon('node_exporter').with(options: '--path.procfs /host/proc --path.sysfs /host/sys --collector.foo --collector.bar --no-collector.baz --no-collector.qux') }
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.13.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/node_exporter-0.13.0.tar.gz') }
        it { is_expected.to contain_file('/opt/node_exporter-0.13.0.linux-amd64/node_exporter') }
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/node_exporter').with('target' => '/opt/node_exporter-0.13.0.linux-amd64/node_exporter') }
        end
      end
    end
  end
end
