require 'spec_helper'

describe 'mongodb::opsmanager' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) do
        {
          opsmanager_url: 'http://localhost:8080'
        }
      end

      describe 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_class('mongodb::opsmanager::install').
            that_notifies('Class[mongodb::opsmanager::config]')
        }

        it {
          is_expected.to contain_class('mongodb::opsmanager::config').
            that_notifies('Class[mongodb::opsmanager::service]')
        }

        it { is_expected.to contain_class('mongodb::opsmanager::service') }

        it { is_expected.to contain_service('mongodb') }

        it { is_expected.to contain_service('mongodb-mms') }

        it { is_expected.to create_package('mongodb-mms').with_ensure('present') }
      end
    end
  end
end
