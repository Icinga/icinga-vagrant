require 'spec_helper_acceptance'

volume_name = 'test-volume'

if fact('osfamily') == 'windows'
  docker_args = 'docker_ee => true'
  command = '"/cygdrive/c/Program Files/Docker/docker"'
elsif 'osfamily' == 'RedHat'
  docker_args = "repo_opt => '--enablerepo=localmirror-extras'"
  command = 'docker'
elsif fact('os.name') == 'Ubuntu' && fact('os.release.full') == '14.04'
  docker_args = "version => '18.06.1~ce~3-0~ubuntu'"
  command = 'docker'
else
  docker_args = ''
  command = 'docker'
end

describe 'docker volume' do
  before(:all) do
    retry_on_error_matching(60, 5, %r{connection failure running}) do
      install_pp = "class { 'docker': #{docker_args} }"
      apply_manifest(install_pp, catch_failures: true)
    end
  end

  it 'exposes volume subcommand' do
    shell("#{command} volume --help", acceptable_exit_codes: [0])
  end

  context 'with a local volume described in Puppet' do
    it 'applies idempotently' do
      pp = <<-MANIFEST
        docker_volume { '#{volume_name}':
          ensure => present,
        }
      MANIFEST

      idempotent_apply(default, pp, {})
    end

    it 'has created a volume' do
      shell("#{command} volume inspect #{volume_name}", acceptable_exit_codes: [0])
    end

    after(:all) do
      shell("#{command} volume rm #{volume_name}")
    end
  end
end
