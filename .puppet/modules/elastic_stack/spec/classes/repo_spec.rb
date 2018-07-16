require 'spec_helper'

def url(format, version)
  case version
  when %r{^2}
    repo_type = (format == 'yum') ? 'centos' : 'debian'
    "https://packages.elastic.co/elasticsearch/#{version}/#{repo_type}"
  else
    "https://artifacts.elastic.co/packages/#{version}/#{format}"
  end
end

def declare_apt(version: '6.x', **params)
  params[:location] ||= url('apt', version)
  contain_apt__source('elastic').with(params)
end

def declare_yum(version: '6.x', **params)
  params[:baseurl] ||= url('yum', version)
  contain_yumrepo('elastic').with(params)
end

def declare_zypper(version: '6.x', **params)
  params[:baseurl] ||= url('yum', version)
  contain_zypprepo('elastic').with(params)
end

describe 'elastic_stack::repo', type: 'class' do
  default_params = {}
  rpm_key_cmd = 'rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'

  on_supported_os(facterversion: '2.4').each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:os]['family']
      when 'Debian'
        it { is_expected.to declare_apt }
      when 'RedHat'
        it { is_expected.to declare_yum }
      when 'Suse'
        it { is_expected.to declare_zypper }
        it { is_expected.to contain_exec('elastic_suse_import_gpg').with(command: rpm_key_cmd) }
        it { is_expected.to contain_exec('elastic_zypper_refresh_elastic').with(command: 'zypper refresh elastic') }
      end

      context 'with "version => 2"' do
        let(:params) { default_params.merge(version: 2) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(version: '2.x') }
        when 'RedHat'
          it { is_expected.to declare_yum(version: '2.x') }
        when 'Suse'
          it { is_expected.to declare_zypper(version: '2.x') }
        end
      end

      context 'with "version => 5"' do
        let(:params) { default_params.merge(version: 5) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(version: '5.x') }
        when 'RedHat'
          it { is_expected.to declare_yum(version: '5.x') }
        when 'Suse'
          it { is_expected.to declare_zypper(version: '5.x') }
        end
      end

      context 'with "priority => 99"' do
        let(:params) { default_params.merge(priority: 99) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(pin: 99) }
        when 'RedHat'
          it { is_expected.to declare_yum(priority: 99) }
        when 'Suse'
          it { is_expected.to declare_zypper(priority: 99) }
        end
      end

      context 'with "prerelease => true"' do
        let(:params) { default_params.merge(prerelease: true) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(version: '6.x-prerelease') }
        when 'RedHat'
          it { is_expected.to declare_yum(version: '6.x-prerelease') }
        when 'Suse'
          it { is_expected.to declare_zypper(version: '6.x-prerelease') }
        end
      end

      context 'with "oss => true"' do
        let(:params) { default_params.merge(oss: true) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(version: 'oss-6.x') }
        when 'RedHat'
          it { is_expected.to declare_yum(version: 'oss-6.x') }
        when 'Suse'
          it { is_expected.to declare_zypper(version: 'oss-6.x') }
        end
      end

      context 'with "oss and prerelease => true"' do
        let(:params) { default_params.merge(oss: true, prerelease: true) }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to declare_apt(version: 'oss-6.x-prerelease') }
        when 'RedHat'
          it { is_expected.to declare_yum(version: 'oss-6.x-prerelease') }
        when 'Suse'
          it { is_expected.to declare_zypper(version: 'oss-6.x-prerelease') }
        end
      end

      context 'with proxy parameter' do
        let(:params) { default_params.merge(proxy: 'http://proxy.com:8080') }

        it { is_expected.to declare_yum(proxy: 'http://proxy.com:8080') } if facts[:os]['family'] == 'RedHat'
      end
    end
  end
end
