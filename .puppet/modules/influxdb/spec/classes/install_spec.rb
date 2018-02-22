require 'spec_helper'

describe 'influxdb::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        let(:pre_condition) do
          <<-EOS
include influxdb
          EOS
        end

        it { is_expected.not_to contain_class('influxdb::repo') }

        it do
          is_expected.to contain_package('influxdb').with(ensure: 'installed',
                                                          tag: 'influxdb')
        end

        it { is_expected.to contain_class('influxdb') }

        it { is_expected.to contain_class('influxdb::install') }
        it { is_expected.to compile.with_all_deps }
      end

      describe 'when $manage_repos=true' do
        let(:pre_condition) do
          <<-EOS

          class { 'influxdb':
            manage_repos => true,
          }

          EOS
        end
        case facts[:osfamily]
        when 'Archlinux'
          next
        when 'Debian'
          let(:contained_class) { 'influxdb::repo::apt' }
        when 'RedHat'
          let(:contained_class) { 'influxdb::repo::yum' }
        end

        it { is_expected.to contain_class(contained_class).that_comes_before('Class[influxdb::repo]') }
        it { is_expected.to contain_class('influxdb::repo').that_comes_before('Class[influxdb::install]') }
        it { is_expected.to contain_class('influxdb::install').that_comes_before('Class[influxdb::config]') }
      end
    end
  end
end
