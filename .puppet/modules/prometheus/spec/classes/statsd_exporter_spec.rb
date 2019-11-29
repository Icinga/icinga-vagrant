require 'spec_helper'

describe 'prometheus::statsd_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.8.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url',
            mappings: [
              {
                match: 'test.dispatcher.*.*.*',
                name: 'dispatcher_events_total',
                labels: {
                  processor: '$1',
                  action: '$2',
                  outcome: '$3',
                  job: 'test_dispatcher'
                }
              },
              {
                match: '*.signup.*.*',
                name: 'signup_events_total',
                labels: {
                  provider: '$2',
                  outcome: '$3',
                  job: '${1}_server'
                }
              }
            ]
          }
        end

        it { is_expected.to contain_archive('/tmp/statsd_exporter-0.8.0.tar.gz') }

        describe 'compile manifest' do
          it { is_expected.to compile.with_all_deps }
        end

        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/statsd_exporter').with('target' => '/opt/statsd_exporter-0.8.0.linux-amd64/statsd_exporter') }
        end

        describe 'required resources' do
          it { is_expected.to contain_prometheus__daemon('statsd_exporter').with(options: "--statsd.mapping-config='/etc/statsd-exporter-mapping.yaml' ") }
          it { is_expected.to contain_user('statsd-exporter') }
          it { is_expected.to contain_group('statsd-exporter') }
          it { is_expected.to contain_service('statsd_exporter') }
        end

        describe 'mapping config file' do
          it {
            is_expected.to contain_file('/etc/statsd-exporter-mapping.yaml').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'statsd-exporter',
              'mode'    => '0640',
              'notify'  => 'Service[statsd_exporter]',
              'content' => <<-YAML.gsub(%r{^\s+\|}, '')
                |---
                |mappings:
                |- match: test.dispatcher.*.*.*
                |  name: dispatcher_events_total
                |  labels:
                |    processor: "$1"
                |    action: "$2"
                |    outcome: "$3"
                |    job: test_dispatcher
                |- match: "*.signup.*.*"
                |  name: signup_events_total
                |  labels:
                |    provider: "$2"
                |    outcome: "$3"
                |    job: "${1}_server"
              YAML
            )
          }
        end
      end

      context 'with older version that does not support posix like option flags specified' do
        let(:params) do
          {
            version: '0.6.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'compile manifest' do
          it { is_expected.to compile.with_all_deps }
        end

        it { is_expected.to contain_prometheus__daemon('statsd_exporter').with(options: "-statsd.mapping-config='/etc/statsd-exporter-mapping.yaml' ") }
      end
    end
  end
end
