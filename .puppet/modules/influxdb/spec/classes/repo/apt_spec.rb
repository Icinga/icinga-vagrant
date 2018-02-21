require 'spec_helper'

describe 'influxdb::repo::apt' do
  on_supported_os.each do |os, facts|
    # A little ugly, but we only want to run our tests for Debian based machines.
    next unless facts[:operatingsystem] == 'Debian'

    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default params' do
        let(:_operatingsystem) { facts[:operatingsystem].downcase }

        let(:key) do
          {
            'id'     => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
            'source' => 'https://repos.influxdata.com/influxdb.key'
          }
        end

        let(:include) do
          {
            'src' => false
          }
        end

        it do
          is_expected.to contain_apt__source('repos.influxdata.com').with(ensure: 'present',
                                                                          location: "https://repos.influxdata.com/#{_operatingsystem}",
                                                                          release: facts[:lsbdistcodename],
                                                                          repos: 'stable',
                                                                          key: key,
                                                                          include: include)
        end

        it { is_expected.to contain_class('influxdb::repo::apt') }
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
