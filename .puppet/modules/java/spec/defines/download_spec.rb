require 'spec_helper'

url = 'http://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz'

describe 'java::download', type: :define do
  context 'with CentOS 64-bit' do
    let(:facts) { { kernel: 'Linux', os: { family: 'RedHat', architecture: 'x86_64', name: 'CentOS', release: { full: '6.0' } } } }

    context 'when passing URL to url parameter' do
      let(:params) do
        {
          ensure: 'present',
          version_major: '8u201',
          version_minor: 'b09',
          java_se: 'jdk',
          url: $url,
        }
      end
      let(:title) { 'jdk8' }

      it {
        is_expected.to contain_archive('/tmp/jdk-8u201-linux-x64.rpm')
      }
    end

    context 'when no url provided' do
      let(:params) do
        {
          ensure: 'present',
          version_major: '8u201',
          version_minor: 'b09',
          java_se: 'jdk',
        }
      end
      let(:title) { 'jdk8' }

      it {
        is_expected.to raise_error Puppet::Error
      }
    end

    context 'when manage_symlink is set to true' do
      let(:params) do
        {
          ensure: 'present',
          version: '6',
          java_se: 'jdk',
          basedir: '/usr/java',
          manage_symlink: true,
          symlink_name: 'java_home',
          url: $url,
        }
      end
      let(:title) { 'jdk6' }

      it { is_expected.to contain_file('/usr/java/java_home') }
    end
  end

  context 'with Ubuntu 64-bit' do
    let(:facts) { { kernel: 'Linux', os: { family: 'Debian', architecture: 'amd64', name: 'Ubuntu', release: { full: '16.04' } } } }

    context 'when passing URL to url parameter' do
      let(:params) { { ensure: 'present', version_major: '8u201', version_minor: 'b09', java_se: 'jdk', url: $url } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u201-linux-x64.tar.gz') }
    end
  end
  describe 'incompatible OSes' do
    [
      {
        kernel: 'Windows',
        os: {
          family: 'Windows',
          name: 'Windows',
          release: {
            full: '8.1',
          },
        },
      },
      {
        kernel: 'Darwin',
        os: {
          family: 'Darwin',
          name: 'Darwin',
          release: {
            full: '13.3.0',
          },
        },
      },
      {
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '7100-02-00-000',
          },
        },
      },
      {
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '6100-07-04-1216',
          },
        },
      },
      {
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '5300-12-01-1016',
          },
        },
      },
    ].each do |facts|
      let(:facts) { facts }
      let(:title) { 'jdk' }

      it "is_expected.to fail on #{facts[:os][:name]} #{facts[:os][:release][:full]}" do
        expect { catalogue }.to raise_error Puppet::Error, %r{unsupported platform}
      end
    end
  end
end
