require 'spec_helper_acceptance'

shared_examples 'a logstash installer' do
  it "should install logstash version #{LS_VERSION}" do
    expect(shell('/opt/logstash/bin/logstash --version').stdout).to eq("logstash #{LS_VERSION}\n")
  end

  describe package('logstash') do
    it { should be_installed }
  end

  describe service('logstash') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/var/run/logstash.pid') do
    it { should be_file }
    its(:content) { should match(/^[0-9]+$/) }
  end

  it 'should spawn a single logstash process' do
    expect(logstash_process_list.length).to eq(1)
  end

  it 'should run logstash as the "logstash" user' do
    expect(logstash_process_list.pop).to match(/^logstash /)
  end
end

describe 'class logstash' do
  describe 'ensure => present' do
    context 'with basic arguments' do
      before(:all) do
        remove_logstash
        install_logstash
      end

      it_behaves_like 'a logstash installer'

      it 'should be idempotent' do
        if fact('lsbdistdescription') =~ /debian.*jessie/i
          skip('https://github.com/elastic/puppet-logstash/issues/266')
        end
        expect_no_change_from_manifest(install_logstash_manifest)
      end
    end

    context 'when installing from an http url' do
      before(:all) do
        remove_logstash
        install_logstash("package_url => '#{logstash_package_url}'")
      end

      it_behaves_like 'a logstash installer'
    end

    context 'when installing from a local file' do
      before(:all) do
        remove_logstash
        install_logstash_from_local_file
      end

      it_behaves_like 'a logstash installer'
    end

    context 'when installing from a "puppet://" url' do
      before(:all) do
        remove_logstash
        install_logstash(
          "package_url => 'puppet:///modules/logstash/#{logstash_package_filename}'"
        )
      end

      it_behaves_like 'a logstash installer'
    end
  end

  describe 'ensure => absent' do
    before(:context) do
      install_logstash_from_local_file
      remove_logstash
    end

    it 'should be idempotent' do
      if fact('lsbdistdescription') =~ /debian.*jessie/i
        skip('https://github.com/elastic/puppet-logstash/issues/266')
      end
      expect_no_change_from_manifest(remove_logstash_manifest)
    end

    describe package('logstash') do
      it { should_not be_installed }
    end

    describe service('logstash') do
      it { should_not be_running }
      it 'should not be enabled' do
        if fact('lsbdistdescription') =~ /debian.*jessie/i
          skip('https://github.com/elastic/puppet-logstash/issues/266')
        end
        should_not be_enabled
      end
    end
  end

  describe 'init_defaults parameter' do
    context "with 'LS_USER' => 'root'" do
      before do
        init_defaults = "{ 'LS_USER' => 'root' }"
        install_logstash_from_local_file("init_defaults => #{init_defaults}")
      end

      it 'should run logstash as root' do
        expect(logstash_process_list.pop).to match(/^root /)
      end
    end
  end
end
