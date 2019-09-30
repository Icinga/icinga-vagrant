require 'beaker-rspec'
require 'net/http'
require 'pry'
require 'securerandom'
require 'yaml'

# Collect global options from the environment.
if ENV['LOGSTASH_VERSION'].nil?
  raise 'Please set the LOGSTASH_VERSION environment variable.'
end
LS_VERSION = ENV['LOGSTASH_VERSION']
PUPPET_VERSION = ENV['PUPPET_VERSION'] || '4.10.7'

PE_VERSION = ENV['BEAKER_PE_VER'] || ENV['PE_VERSION'] || '3.8.3'
PE_DIR = ENV['BEAKER_PE_DIR']

if LS_VERSION =~ /(alpha|beta|rc)/
  IS_PRERELEASE = true
else
  IS_PRERELEASE = false
end

def agent_version_for_puppet_version(puppet_version)
  # REF: https://docs.puppet.com/puppet/latest/reference/about_agent.html
  version_map = {
    # Puppet => Agent
    '4.9.4' => '1.9.3',
    '4.8.2' => '1.8.3',
    '4.8.1' => '1.8.2',
    '4.8.0' => '1.8.0',
    '4.7.1' => '1.7.2',
    '4.7.0' => '1.7.1',
    '4.6.2' => '1.6.2',
    '4.6.1' => '1.6.1',
    '4.6.0' => '1.6.0',
    '4.5.3' => '1.5.3',
    '4.4.2' => '1.4.2',
    '4.4.1' => '1.4.1',
    '4.4.0' => '1.4.0',
    '4.3.2' => '1.3.6',
    '4.3.1' => '1.3.2',
    '4.3.0' => '1.3.0',
    '4.2.3' => '1.2.7',
    '4.2.2' => '1.2.6',
    '4.2.1' => '1.2.2',
    '4.2.0' => '1.2.1',
    '4.1.0' => '1.1.1',
    '4.0.0' => '1.0.1'
  }
  version_map[puppet_version]
end

def apply_manifest_fixture(manifest_name)
  manifest = File.read("./spec/fixtures/manifests/#{manifest_name}.pp")
  apply_manifest(manifest, catch_failures: true)
end

def expect_no_change_from_manifest(manifest)
  expect(apply_manifest(manifest).exit_code).to eq(0)
end

def http_package_url
  url_root = "https://artifacts.elastic.co/downloads/logstash/logstash-#{LS_VERSION}"

  case fact('osfamily')
  when 'Debian'
    "#{url_root}.deb"
  when 'RedHat', 'Suse'
    "#{url_root}.rpm"
  end
end

def local_file_package_url
  "file:///tmp/#{logstash_package_filename}"
end

def puppet_fileserver_package_url
  "puppet:///modules/logstash/#{logstash_package_filename}"
end

def logstash_package_filename
  File.basename(http_package_url)
end

def logstash_package_version
  if LS_VERSION =~ /(alpha|beta|rc)/
    package_version = LS_VERSION.gsub('-', '~')
  else
    package_version = LS_VERSION
  end

  case fact('osfamily') # FIXME: Put this logic in the module, not the tests.
  when 'RedHat'
    "#{package_version}-1"
  when 'Debian', 'Suse'
    "1:#{package_version}-1"
  end
end

def logstash_config_manifest
  <<-END
  logstash::configfile { 'basic_config':
    content => 'input { tcp { port => 2000 } } output { null {} }'
  }
  END
end

def install_logstash_manifest(extra_args = nil)
  <<-END
  class { 'elastic_stack::repo':
    version    => #{LS_VERSION[0]},
    prerelease => #{IS_PRERELEASE.to_s},
  }
  class { 'logstash':
    manage_repo  => true,
    version      => '#{logstash_package_version}',
    #{extra_args if extra_args}
  }

  #{logstash_config_manifest}
  END
end

def include_logstash_manifest()
  <<-END
  class { 'elastic_stack::repo':
    version    => #{LS_VERSION[0]},
    prerelease => #{IS_PRERELEASE.to_s},
  }

  include logstash

  #{logstash_config_manifest}
  END
end

def install_logstash_from_url_manifest(url, extra_args = nil)
  <<-END
  class { 'logstash':
    package_url  => '#{url}',
    #{extra_args if extra_args}
  }

  #{logstash_config_manifest}
  END
end

def install_logstash_from_local_file_manifest(extra_args = nil)
  install_logstash_from_url_manifest(local_file_package_url, extra_args)
end

def remove_logstash_manifest
  "class { 'logstash': ensure => 'absent' }"
end

def stop_logstash_manifest
  "class { 'logstash': status => 'disabled' }"
end

# Provide a basic Logstash install. Useful as a testing pre-requisite.
def install_logstash(extra_args = nil)
  result = apply_manifest(install_logstash_manifest(extra_args), catch_failures: true)
  sleep 5 # FIXME: This is horrible.
  return result
end

def include_logstash
  result = apply_manifest(include_logstash_manifest, catch_failures: true, debug: true)
  sleep 5 # FIXME: This is horrible.
  return result
end

def install_logstash_from_url(url, extra_args = nil)
  manifest = install_logstash_from_url_manifest(url, extra_args)
  result = apply_manifest(manifest, catch_failures: true)
  sleep 5 # FIXME: This is horrible.
  return result
end

def install_logstash_from_local_file(extra_args = nil)
  install_logstash_from_url(local_file_package_url, extra_args)
end

def remove_logstash
  result = apply_manifest(remove_logstash_manifest)
  sleep 5 # FIXME: This is horrible.
  return result
end

def stop_logstash
  result = apply_manifest(stop_logstash_manifest, catch_failures: true)
  shell('ps -eo comm | grep java | xargs kill -9', accept_all_exit_codes: true)
  sleep 5 # FIXME: This is horrible.
  return result
end

def logstash_process_list
  ps_cmd = 'ps -ww --no-headers -C java -o user,command | grep logstash'
  shell(ps_cmd, accept_all_exit_codes: true).stdout.split("\n")
end

def logstash_settings
  YAML.load(shell('cat /etc/logstash/logstash.yml').stdout)
end

def expect_setting(setting, value)
  expect(logstash_settings[setting]).to eq(value)
end

def pipelines_from_yaml
  YAML.load(shell('cat /etc/logstash/pipelines.yml').stdout)
end

def service_restart_message
  "Service[logstash]: Triggered 'refresh'"
end

def pe_package_url
  distro, distro_version = ENV['BEAKER_set'].split('-')
  case distro
  when 'debian'
    os = 'debian'
    arch = 'amd64'
  when 'centos'
    os = 'el'
    arch = 'x86_64'
  when 'ubuntu'
    os = 'ubuntu'
    arch = 'amd64'
  end
  url_root = "https://s3.amazonaws.com/pe-builds/released/#{PE_VERSION}"
  url = "#{url_root}/puppet-enterprise-#{PE_VERSION}-#{os}-#{distro_version}-#{arch}.tar.gz"
end

def pe_package_filename
  File.basename(pe_package_url)
end

def puppet_enterprise?
  ENV['BEAKER_IS_PE'] == 'true' || ENV['IS_PE'] == 'true'
end

hosts.each do |host|
  # Install Puppet
  if puppet_enterprise?
    pe_download = File.join(PE_DIR, pe_package_filename)
    `curl -s -o #{pe_download} #{pe_package_url}` unless File.exist?(pe_download)
    on host, "hostname #{host.name}"
    install_pe_on(host, pe_ver: PE_VERSION)
  else
    if PUPPET_VERSION.start_with?('4.')
      agent_version = agent_version_for_puppet_version(PUPPET_VERSION)
      install_puppet_agent_on(host, puppet_agent_version: agent_version)
    else
      begin
        install_puppet_on(host, version: PUPPET_VERSION)
      rescue
        install_puppet_from_gem_on(host, version: PUPPET_VERSION)
      end
    end
  end

  if fact('osfamily') == 'Suse'
    if fact('operatingsystem') == 'OpenSuSE'
      install_package host, 'ruby-devel augeas-devel libxml2-devel'
      on host, 'gem install ruby-augeas --no-ri --no-rdoc'
    end
  end

  # Update package cache for those who need it.
  on host, 'apt-get update' if fact('osfamily') == 'Debian'

  # Aquire a binary package of Logstash.
  logstash_download = "spec/fixtures/artifacts/#{logstash_package_filename}"
  `curl -s -o #{logstash_download} #{http_package_url}` unless File.exist?(logstash_download)
  # ...send it to the test host
  scp_to(host, logstash_download, '/tmp/')
  # ...and also make it available as a "puppet://" url, by putting it in the
  # 'files' directory of the Logstash module.
  FileUtils.cp(logstash_download, './files/')

  # ...and put some grok pattern examples in their too.
  Dir.glob('./spec/fixtures/grok-patterns/*').each do |f|
    FileUtils.cp(f, './files/')
  end

  # Provide a Logstash plugin as a local Gem.
  scp_to(host, './spec/fixtures/plugins/logstash-output-cowsay-5.0.0.gem', '/tmp/')

  # ...and another plugin that can be fetched from Puppet with "puppet://"
  FileUtils.cp('./spec/fixtures/plugins/logstash-output-cowthink-5.0.0.gem', './files/')

  # ...and yet another plugin, this time packaged as an offline installer
  FileUtils.cp('./spec/fixtures/plugins/logstash-output-cowsay-5.0.0.zip', './files/')

  # Provide a config file template.
  FileUtils.cp('./spec/fixtures/templates/configfile-template.erb', './templates/')

  # Provide this module to the test system.
  project_root = File.dirname(File.dirname(__FILE__))
  install_dev_puppet_module_on(host, source: project_root, module_name: 'logstash')

  # Also install any other modules we need on the test system.
  install_puppet_module_via_pmt_on(host, module_name: 'elastic-elastic_stack')
  install_puppet_module_via_pmt_on(host, module_name: 'darin-zypprepo')
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.color = true

  # declare an exclusion filter
  c.filter_run_excluding broken: true
end
