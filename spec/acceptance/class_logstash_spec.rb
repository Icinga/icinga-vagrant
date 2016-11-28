require 'spec_helper_acceptance'

shared_examples 'a logstash installer' do
  it "should install logstash version #{LS_VERSION}" do
    expect(shell('/usr/share/logstash/bin/logstash --version').stdout).to eq("logstash #{LS_VERSION}\n")
  end

  case fact('osfamily')
  when 'RedHat', 'Suse'
    describe package('logstash') do
      it { should be_installed }
    end
  when 'Debian'
    # Serverspec has been falsely reporting the package as not installed on
    # Debian 7, so we'll implement our own version of "should be_installed".
    it "should install logstash package version #{logstash_package_version}" do
      apt_output = shell('apt-cache policy logstash').stdout
      expect(apt_output).to include("Installed: #{logstash_package_version}")
    end
  end

  describe service('logstash') do
    it { should be_enabled }
    it { should be_running }
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
    context 'with include-like declaration' do
      before(:all) do
        remove_logstash
        include_logstash
      end

      it_behaves_like 'a logstash installer'

      it 'should be idempotent' do
        expect_no_change_from_manifest(install_logstash_manifest)
      end
    end

    context 'when installing from an http url' do
      before(:all) do
        remove_logstash
        install_logstash_from_url(http_package_url)
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
        install_logstash_from_url(puppet_fileserver_package_url)
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
      expect_no_change_from_manifest(remove_logstash_manifest)
    end

    describe package('logstash') do
      it { should_not be_installed }
    end

    describe service('logstash') do
      it { should_not be_running }
      it 'should not be enabled' do
        should_not be_enabled
      end
    end
  end

  describe 'startup_options parameter' do
    context "with 'LS_USER' => 'root'" do
      before do
        startup_options = "{ 'LS_USER' => 'root' }"
        install_logstash_from_local_file("startup_options => #{startup_options}")
      end

      it 'should run logstash as root' do
        expect(logstash_process_list.pop).to match(/^root /)
      end
    end
  end
end
