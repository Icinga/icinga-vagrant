require 'spec_helper'

describe 'influxdb::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        case facts[:osfamily]
        when 'Archlinux'
          next
        when 'Debian'
          let(:contained_class) { 'influxdb::repo::apt' }
          let(:not_contained_class) { 'influxdb::repo::yum' }
        when 'RedHat'
          let(:contained_class) { 'influxdb::repo::yum' }
          let(:not_contained_class) { 'influxdb::repo::apt' }
        end

        it { is_expected.to contain_class(contained_class) }
        it { is_expected.not_to contain_class(not_contained_class) }

        it { is_expected.to contain_class('influxdb::repo') }
        it { is_expected.to compile.with_all_deps }

        # ordering tests
        it { is_expected.to contain_class(contained_class).that_comes_before('Class[influxdb::repo]') }
      end
      describe 'should fail when not-supported OS' do
        let(:facts) do
          facts.merge(osfamily: 'foobar')
        end

        it { is_expected.to compile.and_raise_error(%r{Unsupported managed repository}) }
      end
    end
  end
end
