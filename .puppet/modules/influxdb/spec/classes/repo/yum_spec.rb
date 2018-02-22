require 'spec_helper'

describe 'influxdb::repo::yum' do
  on_supported_os.each do |os, facts|
    # A little ugly, but we only want to run our tests for RHEL based machines.
    next unless facts[:osfamily] == 'RedHat'

    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        let(:_operatingsystem) do
          case facts[:operatingsystem]
          when 'CentOS'
            facts[:operatingsystem].downcase
          else
            'rhel'
          end
        end

        it do
          is_expected.to contain_yumrepo('repos.influxdata.com').with(ensure: 'present',
                                                                      baseurl: "https://repos.influxdata.com/#{_operatingsystem}/\$releasever/\$basearch/stable",
                                                                      enabled: 1,
                                                                      gpgcheck: 1,
                                                                      gpgkey: 'https://repos.influxdata.com/influxdb.key')
        end

        it { is_expected.to contain_class('influxdb::repo::yum') }
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
