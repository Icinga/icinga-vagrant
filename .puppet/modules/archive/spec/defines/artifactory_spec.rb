require 'spec_helper'

describe 'archive::artifactory' do
  let(:facts) { { os: { family: 'RedHat' }, puppetversion: '4.4.0' } }

  # Mock Puppet V4 API ruby function with a puppet language function equivalent
  let(:pre_condition) do
    'function archive::artifactory_checksum($url,$type) { return \'0d4f4b4b039c10917cfc49f6f6be71e4\' }'
  end

  context 'artifactory archive with defaults' do
    let(:title) { '/opt/app/example.zip' }
    let(:params) do
      {
        url: 'http://home.lan:8081/artifactory/path/example.zip'
      }
    end

    it do
      is_expected.to contain_archive('/opt/app/example.zip').with(
        path: '/opt/app/example.zip',
        source: 'http://home.lan:8081/artifactory/path/example.zip',
        checksum: '0d4f4b4b039c10917cfc49f6f6be71e4',
        checksum_type: 'sha1'
      )
    end

    it do
      is_expected.to contain_file('/opt/app/example.zip').with(
        owner: '0',
        group: '0',
        mode: '0640',
        require: 'Archive[/opt/app/example.zip]'
      )
    end
  end

  context 'artifactory archive with path' do
    let(:title) { 'example.zip' }
    let(:params) do
      {
        archive_path: '/opt/app',
        url: 'http://home.lan:8081/artifactory/path/example.zip',
        owner: 'app',
        group: 'app',
        mode: '0400'
      }
    end

    it do
      is_expected.to contain_archive('/opt/app/example.zip').with(
        path: '/opt/app/example.zip',
        source: 'http://home.lan:8081/artifactory/path/example.zip',
        checksum: '0d4f4b4b039c10917cfc49f6f6be71e4',
        checksum_type: 'sha1'
      )
    end

    it do
      is_expected.to contain_file('/opt/app/example.zip').with(
        owner: 'app',
        group: 'app',
        mode: '0400',
        require: 'Archive[/opt/app/example.zip]'
      )
    end
  end
end
