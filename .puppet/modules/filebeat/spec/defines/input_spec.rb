require 'spec_helper'

describe 'filebeat::input' do
  let :pre_condition do
    'class { "filebeat":
        outputs => {
          "logstash" => {
            "hosts" => [
              "localhost:5044",
            ],
          },
        },
      }'
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) { 'test-logs' }
      let(:params) do
        {
          'paths' => [
            '/var/log/auth.log',
            '/var/log/syslog',
          ],
          'doc_type' => 'syslog-beat',
        }
      end

      if os_facts[:kernel] != 'windows'
        it { is_expected.to compile }
      end

      it {
        is_expected.to contain_file('filebeat-test-logs').with(
          notify: 'Service[filebeat]',
        )
      }
    end

    context "with docker input support on #{os}" do
      let(:facts) { os_facts }

      # Docker Support
      let(:title) { 'docker' }
      let(:params) do
        {
          'input_type' => 'docker',
        }
      end

      if os_facts[:kernel] != 'windows'
        it { is_expected.to compile }

        it {
          is_expected.to contain_file('filebeat-docker').with(
            notify: 'Service[filebeat]',
          )
          is_expected.to contain_file('filebeat-docker').with_content(
            %r{- type: docker\n\s{2}containers:\n\s{4}ids:\n\s{4}- '\*'\n\s{4}path: /var/lib/docker/containers\n\s{4}stream: all\n\s{2}combine_partial: false\n\s{2}cri.parse_flags: false\n},
          )
        }
      end
    end
  end

  context 'with no parameters' do
    let(:title) { 'test-logs' }
    let(:params) do
      {
        'paths' => [
          '/var/log/auth.log',
          '/var/log/syslog',
        ],
        'doc_type' => 'syslog-beat',
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
  end
end
