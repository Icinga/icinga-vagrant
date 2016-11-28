require 'spec_helper'

describe 'filebeat::prospector', :type => :define do
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
  let :title do
    'test-logs'
  end

  context 'with no parameters' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'On Linux' do
    let :facts do {
      :kernel => 'Linux',
      :osfamily => 'Linux',
      :rubyversion => '2.3.1',
      :filebeat_version => '1',
    }
    end

    context 'with file blobs set' do
      let :params do
        {
          :paths => [
            '/var/log/apache2/*.log',
          ],
          :doc_type => 'apache',
        }
      end

      it { is_expected.to contain_file('filebeat-test-logs').with(
        :path => '/etc/filebeat/conf.d/test-logs.yml',
        :mode => '0644',
        :content => 'filebeat:
  prospectors:
    - paths:
      - /var/log/apache2/*.log
      encoding: plain
      fields_under_root: false
      input_type: log
      document_type: apache
      scan_frequency: 10s
      harvester_buffer_size: 16384
      tail_files: false
      force_close_files: false
      backoff: 1s
      max_backoff: 10s
      backoff_factor: 2
      max_bytes: 10485760
',
      )}
    end
    context 'with some java like multiline settings' do
      let :params do
        {
          :paths => [
            '/var/log/java_app/some.log',
          ],
          :doc_type => 'java_app',
          :exclude_lines => [
            '^DEBUG',
          ],
          :include_lines => [
            '^ERROR',
            '^WARN',
          ],
          :exclude_files => [
            '.gz$',
          ],
          :multiline => {
            'pattern' => '^\[',
            'negate' => 'true',
            'match' => 'after',
          },
        }
      end

      it { is_expected.to contain_file('filebeat-test-logs').with(
        :path => '/etc/filebeat/conf.d/test-logs.yml',
        :mode => '0644',
        :content => 'filebeat:
  prospectors:
    - paths:
      - /var/log/java_app/some.log
      exclude_files:
        - .gz$
      encoding: plain
      fields_under_root: false
      input_type: log
      document_type: java_app
      scan_frequency: 10s
      harvester_buffer_size: 16384
      tail_files: false
      force_close_files: false
      backoff: 1s
      max_backoff: 10s
      backoff_factor: 2
      max_bytes: 10485760
      multiline:
        pattern: \'^\[\'
        negate: true
        match: after
      include_lines:
        - \'^ERROR\'
        - \'^WARN\'
      exclude_lines:
        - \'^DEBUG\'
',
      )}
    end
  end

  context 'On Windows' do
    let :facts do {
      :kernel => 'Windows',
      :rubyversion => '2.3.1',
      :filebeat_version => '1',
    }
    end

    context 'with file blobs set' do
      let :params do
        {
          :paths => [
            'C:/Program Files/Apache Software Foundation/Apache2.2/*.log',
          ],
          :doc_type => 'apache',
        }
      end

      it { is_expected.to contain_file('filebeat-test-logs').with(
        :path => 'C:/Program Files/Filebeat/conf.d/test-logs.yml',
        :content => 'filebeat:
  prospectors:
    - paths:
      - C:/Program Files/Apache Software Foundation/Apache2.2/*.log
      encoding: plain
      fields_under_root: false
      input_type: log
      document_type: apache
      scan_frequency: 10s
      harvester_buffer_size: 16384
      tail_files: false
      force_close_files: false
      backoff: 1s
      max_backoff: 10s
      backoff_factor: 2
      max_bytes: 10485760
',
      )}
    end
  end
end
