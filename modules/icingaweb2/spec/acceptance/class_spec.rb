#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'icingaweb2 class:' do
  it 'runs successfully' do
    pp = "
      class { '::icingaweb2':
        manage_repo    => true,
      }
    "

    apply_manifest(pp, catch_failures: true)
  end

  describe package('icingaweb2') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/icingaweb2/config.ini') do
    it { is_expected.to be_file }
    it { is_expected.to contain '[global]' }
    it { is_expected.to contain '[logging]' }
  end

end
