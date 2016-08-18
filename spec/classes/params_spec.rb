require 'spec_helper'

describe 'influxdb::params', :type => :class do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '12.04',
      :lsbdistcodename => 'precice',
    }
  end
  it { is_expected.to contain_class("influxdb::params") }
end