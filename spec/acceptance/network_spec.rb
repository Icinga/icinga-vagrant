require 'spec_helper_acceptance'

broken = false
command = 'docker'
network_name = 'test-network'

if fact('osfamily') == 'windows'
  puts 'Not implemented on Windows'
  broken = true
elsif fact('osfamily') == 'RedHat'
  docker_args = "repo_opt => '--enablerepo=localmirror-extras'"
elsif fact('os.name') == 'Ubuntu' && fact('os.release.full') == '14.04'
  docker_args = "version => '18.06.1~ce~3-0~ubuntu'"
else
  docker_args = ''
end

describe 'docker network', win_broken: broken do
  before(:all) do
    install_pp = "class { 'docker': #{docker_args}}"
    apply_manifest(install_pp, catch_failures: true)
  end

  describe command("#{command} network --help") do
    its(:exit_status) { is_expected.to eq 0 }
  end

  context 'with a local bridge network described in Puppet' do
    after(:all) do
      shell("#{command} network rm #{network_name}")
    end

    it 'is idempotent' do
      pp = <<-MANIFEST
        docker_network { '#{network_name}':
          ensure => present,
        }
      MANIFEST
      idempotent_apply(default, pp, {})
    end

    it 'has created a network' do
      shell("#{command} network inspect #{network_name}", acceptable_exit_codes: [0])
    end
  end
end
