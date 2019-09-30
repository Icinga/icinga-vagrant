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
    it { should be_running }
    it 'should be_enabled' do
      if fact('lsbdistdescription') =~ /centos release 6/i
        skip('Serverspec seems confused about this on Centos 6.')
      end
      should be_enabled
    end
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

  describe 'service_provider parameter' do
    context "with service_provider => 'openrc'" do
      it 'tries to use openrc as the service provider' do
        log = apply_manifest('class {"logstash": service_provider => "openrc"}').stderr
        expect(log).to include('Provider openrc is not functional on this host')
      end
    end
  end

  describe 'settings parameter' do
    context 'with a flat key' do
      before(:context) do
        settings = "{ 'http.port' => '9999' }"
        install_logstash_from_local_file("settings => #{settings}")
      end

      it 'it sets "http.port" to "9999"' do
        expect_setting('http.port', '9999')
      end

      it 'it retains the default "path.data" setting' do
        expect_setting('path.data', '/var/lib/logstash')
      end

      it 'it retains the default "path.config" setting' do
        expect_setting('path.config', '/etc/logstash/conf.d')
      end

      it 'it retains the default "path.logs" setting' do
        expect_setting('path.logs', '/var/log/logstash')
      end
    end

    context 'with a hierarchical key' do
      before(:context) do
        settings = <<-END
        {
          'pipeline' => {
            'batch' => {
              'size' => 99
            }
          }
        }
        END
        install_logstash_from_local_file("settings => #{settings}")
      end

      it 'sets pipeline batch size to 99 hierarchically' do
        # FIXME: Some Puppet versions put the string "99" in the rendered YAML
        # when it should really be the integer value 99. Logstash is OK with
        # either representation, so we get away with it, but it's not correct.
        expect(logstash_settings['pipeline']['batch']['size'].to_i).to eq(99)
      end
    end

    context 'when a default setting exists' do
      before(:context) do
        settings = "{ 'path.logs' => '/tmp' }"
        install_logstash_from_local_file("settings => #{settings}")
      end

      it 'can override the default' do
        expect_setting('path.logs', '/tmp')
      end
    end
  end

  describe 'startup_options parameter' do
    context "with 'LS_USER' => 'root'" do
      before do
        remove_logstash
        startup_options = "{ 'LS_USER' => 'root' }"
        install_logstash_from_local_file("startup_options => #{startup_options}")
      end

      it 'should run logstash as root' do
        expect(logstash_process_list.pop).to match(/^root /)
      end
    end
  end

  describe 'jvm_options parameter' do
    context "with '-Xms1g'" do
      before(:context) do
        jvm_options = "[ '-Xms1g' ]"
        install_logstash_from_local_file("jvm_options => #{jvm_options}")
      end

      it 'should run java with -Xms1g' do
        expect(logstash_process_list.pop).to include('-Xms1g')
      end

      it 'should not run java with the default of -Xms256m' do
        expect(logstash_process_list.pop).not_to include('-Xms256m')
      end

      it 'should run java with the default "expert" flags' do
        expert_flags = [
          '-Dfile.encoding=UTF-8',
          '-Djava.awt.headless=true',
          '-XX:CMSInitiatingOccupancyFraction=75',
          '-XX:+DisableExplicitGC',
          '-XX:+HeapDumpOnOutOfMemoryError',
          '-XX:+UseCMSInitiatingOccupancyOnly',
          '-XX:+UseConcMarkSweepGC',
          '-XX:+UseParNewGC',
        ]
        expert_flags.each do |flag|
          expect(logstash_process_list.pop).to include(flag)
        end
      end

      context 'when the option is changed' do
        it 'should restart logstash' do
          puppet_log = install_logstash_from_local_file(
            "jvm_options => [ '-Xms512m' ]").stdout
          expect(puppet_log).to include(service_restart_message)
        end

        context 'when restart_on_change is false' do
          it 'should not restart logstash' do
            puppet_log = install_logstash_from_local_file(
              "jvm_options       => [ '-Xms256m' ],
               restart_on_change => false").stdout
            expect(puppet_log).not_to include(service_restart_message)
          end
        end
      end
    end
  end

  describe 'pipelines_parameter' do
    context "with pipelines declared" do
      before(:context) do
        pipelines_puppet = <<-END
        [
          {
            "pipeline.id" => "pipeline_one",
            "path.config" =>  "/etc/path/to/p1.config",
          },
          {
            "pipeline.id" => "pipeline_two",
            "path.config" =>  "/etc/different/path/p2.cfg",
          }
        ]
        END
        install_logstash_from_local_file("pipelines => #{pipelines_puppet}")
      end

      it 'should render them to pipelines.yml' do
        expect(pipelines_from_yaml[0]['pipeline.id']).to eq('pipeline_one')
        expect(pipelines_from_yaml[1]['pipeline.id']).to eq('pipeline_two')
      end

      it 'should remove "path.config" from "logstash.yml"' do
        expect(logstash_settings['path.config']).to be_nil
      end
    end
  end

  describe 'xpack_management_enabled_parameter' do
    context 'when set true with dotted notation' do
      before(:context) do
        settings_puppet_code = '{"xpack.management.enabled" => true}'
        install_logstash_from_local_file("settings => #{settings_puppet_code}")
      end

      it 'should remove "path.config" from "logstash.yml"' do
        expect(logstash_settings['path.config']).to be_nil
      end
    end

    context 'when set true with hierarchical notation' do
      before(:context) do
        settings_puppet_code = <<-END
        {
          "xpack" => {
            "management" => {
              "enabled" => true
            }
          }
        }
        END
        install_logstash_from_local_file("settings => #{settings_puppet_code}")
      end

      it 'should remove "path.config" from "logstash.yml"' do
        expect(logstash_settings['path.config']).to be_nil
      end
    end
  end
end
