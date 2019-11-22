require 'spec_helper'

describe 'mongodb::opsmanager::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'it should create package' do
        let(:pre_condition) { ["class mongodb::opsmanager { $download_url = 'https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.1.50101.20180801T1117Z-1.x86_64.rpm' $package_ensure = 'present' $user = 'mongodb' $group = 'mongodb' $package_name = 'mongodb-mms' }", 'include mongodb::opsmanager'] }

        it {
          is_expected.to contain_package('mongodb-mms').with(ensure: 'present',
                                                             name: 'mongodb-mms')
        }

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
