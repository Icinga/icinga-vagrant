require 'spec_helper_acceptance'

if fact('osfamily') == 'windows'
  install_dir = '/cygdrive/c/Program Files/Docker'
  file_extension = '.exe'
  docker_args = 'docker_ee => true'
  tmp_path = 'C:/cygwin64/tmp'
  test_container = if fact('os.release.major') == '2019'
                     'nanoserver'
                   else
                     'nanoserver-sac2016'
                   end
else
  docker_args = if fact('os.name') == 'RedHat'
                  "repo_opt => '--enablerepo=localmirror-extras'"
                elsif fact('os.name') == 'Centos'
                  "repo_opt => '--enablerepo=localmirror-extras'"
                elsif fact('os.name') == 'Ubuntu' && fact('os.release.full') == '14.04'
                  "version => '18.06.1~ce~3-0~ubuntu'"
                else
                  ''
                end
  install_dir = '/usr/local/bin'
  file_extension = ''
  tmp_path = '/tmp'
  test_container = 'debian'
end

describe 'docker compose' do
  before(:all) do
    retry_on_error_matching(60, 5, %r{connection failure running}) do
      install_code = <<-code
        class { 'docker': #{docker_args} }
        class { 'docker::compose':
          version => '1.23.2',
        }
      code
      apply_manifest(install_code, catch_failures: true)
    end
  end

  context 'Creating compose v3 projects' do
    let(:install_pp) do
      <<-MANIFEST
        docker_compose { 'web':
        compose_files => ['#{tmp_path}/docker-compose-v3.yml'],
        ensure => present,
        }
      MANIFEST
    end

    it 'is idempotent' do
      idempotent_apply(default, install_pp, {})
    end

    it 'has docker compose installed' do
      shell('docker-compose --help', acceptable_exit_codes: [0])
    end

    it 'finds a docker container' do
      shell('docker inspect web_compose_test_1', acceptable_exit_codes: [0])
    end
  end

  context 'creating compose projects with multi compose files' do
    before(:all) do
      install_pp = <<-MANIFEST
        docker_compose { 'web1':
          compose_files => ['#{tmp_path}/docker-compose-v3.yml', '#{tmp_path}/docker-compose-override-v3.yml'],
          ensure => present,
        }
      MANIFEST

      apply_manifest(install_pp, catch_failures: true)
    end

    it "should find container with #{test_container} tag" do
      shell("docker inspect web1_compose_test_1 | grep #{test_container}", acceptable_exit_codes: [0])
    end
  end

  context 'Destroying project with multiple compose files' do
    let(:destroy_pp) do
      <<-MANIFEST
        docker_compose { 'web1':
          compose_files => ['#{tmp_path}/docker-compose-v3.yml', '#{tmp_path}/docker-compose-override-v3.yml'],
          ensure => absent,
        }
      MANIFEST
    end

    before(:all) do
      install_pp = <<-MANIFEST
        docker_compose { 'web1':
          compose_files => ['#{tmp_path}/docker-compose-v3.yml', '#{tmp_path}/docker-compose-override-v3.yml'],
          ensure => present,
        }
      MANIFEST

      apply_manifest(install_pp, catch_failures: true)
    end

    it 'is idempotent' do
      idempotent_apply(default, destroy_pp, {})
    end

    it 'does not find a docker container' do
      shell('docker inspect web1_compose_test_1', acceptable_exit_codes: [1])
    end
  end

  context 'Requesting a specific version of compose' do
    let(:version) do
      '1.21.2'
    end

    it 'is idempotent' do
      pp = <<-MANIFEST
        class { 'docker::compose':
          version => '#{version}',
        }
      MANIFEST
      idempotent_apply(default, pp, {})
    end

    it 'has installed the requested version' do
      shell('docker-compose --version', acceptable_exit_codes: [0]) do |r|
        expect(r.stdout).to match(%r{#{version}})
      end
    end
  end

  context 'Removing docker compose' do
    let(:version) do
      '1.21.2'
    end

    it 'is idempotent' do
      pp = <<-MANIFEST
        class { 'docker::compose':
          ensure  => absent,
          version => '#{version}',
        }
      MANIFEST
      idempotent_apply(default, pp, {})
    end

    it 'has removed the relevant files' do
      shell("test -e \"#{install_dir}/docker-compose#{file_extension}\"", acceptable_exit_codes: [1])
      shell("test -e \"#{install_dir}/docker-compose-#{version}#{file_extension}\"", acceptable_exit_codes: [1])
    end

    after(:all) do
      install_pp = <<-MANIFEST
        class { 'docker': #{docker_args}}
        class { 'docker::compose': }
      MANIFEST
      apply_manifest(install_pp, catch_failures: true)
    end
  end
end
