require 'spec_helper'

describe 'Basic Icinga 2 Installation' do
  context package('icinga2') do
    it { should be_installed }
  end

  context service('icinga2') do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'API Feature' do
  context port(5665) do
    it { should be_listening.with('tcp') }
  end

  context command('curl -u icinga:icinga -k https://localhost:5665/v1') do
    its(:stdout) { should match(%r{Hello from Icinga 2}) }
  end
end

describe 'MySQL IDO Feature' do
  context port(3306) do
    it { should be_listening.with('tcp') }
  end

  context command('mysql -e "select version from icinga_dbversion" icinga2') do
    its(:stdout) { should match(%r{version}) }
  end
end
