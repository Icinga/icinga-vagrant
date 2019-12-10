require 'spec_helper_acceptance'

broken = false

registry_port = 5000

if fact('osfamily') == 'windows'
  win_host = only_host_with_role(hosts, 'default')
  @windows_ip = win_host.ip
  docker_arg = "docker_ee => true, extra_parameters => '\"insecure-registries\": [ \"#{@windows_ip}:5000\" ]'"
  docker_registry_image = 'stefanscherer/registry-windows'
  docker_network = 'nat'
  registry_host = @windows_ip
  config_file = '/cygdrive/c/Users/Administrator/.docker/config.json'
  root_dir = 'C:/Users/Administrator/AppData/Local/Temp'
  server_strip = "#{registry_host}_#{registry_port}"
  bad_server_strip = "#{registry_host}_5001"
  broken = true
else
  docker_args = if fact('osfamily') == 'RedHat'
                  "repo_opt => '--enablerepo=localmirror-extras'"
                elsif fact('os.name') == 'Ubuntu' && fact('os.release.full') == '14.04'
                  "version => '18.06.1~ce~3-0~ubuntu'"
                else
                  ''
                end
  docker_registry_image = 'registry'
  docker_network = 'bridge'
  registry_host = '127.0.0.1'
  server_strip = "#{registry_host}:#{registry_port}"
  bad_server_strip = "#{registry_host}:5001"
  config_file = '/root/.docker/config.json'
  root_dir = '/root'
end

describe 'docker' do
  package_name = 'docker-ce'
  service_name = 'docker'
  command = 'docker'

  context 'When adding system user', win_broken: broken do
    let(:pp) do
      "
             class { 'docker': #{docker_arg}
               docker_users => ['user1']
             }
     "
    end

    it 'the docker daemon' do
      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stdout).not_to match(%r{docker-systemd-reload-before-service})
      end
    end
  end

  context 'with default parameters', win_broken: broken do
    let(:pp) do
      "
			class { 'docker':
        docker_users => [ 'testuser' ],
        #{docker_args}
			}
			docker::image { 'nginx': }
			docker::run { 'nginx':
				image   => 'nginx',
				net     => 'host',
				require => Docker::Image['nginx'],
			}
			docker::run { 'nginx2':
				image   => 'nginx',
				restart => 'always',
				require => Docker::Image['nginx'],
			}
    "
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe command("#{command} version") do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command("#{command} images"), sudo: true do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{nginx} }
    end

    describe command("#{command} inspect nginx"), sudo: true do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command("#{command} inspect nginx2"), sudo: true do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command("#{command} ps --no-trunc | grep `cat /var/run/docker-nginx2.cid`"), sudo: true do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{nginx -g 'daemon off;'} }
    end

    describe command('netstat -tlndp') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{0\.0\.0\.0\:80} }
    end

    describe command('id testuser | grep docker') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match %r{docker} }
    end
  end

  context 'When asked to have the latest image of something', win_broken: broken do
    let(:pp) do
      "
        class { 'docker':
          docker_users => [ 'testuser' ]
        }
	docker::image { 'busybox': ensure => latest }
    "
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'When registry_mirror is set', win_broken: broken do
    let(:pp) do
      "
      class { 'docker':
        registry_mirror => 'http://testmirror.io'
      }
    "
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'has a registry mirror set' do
      shell('ps -aux | grep docker') do |r|
        expect(r.stdout).to match(%r{--registry-mirror=http:\/\/testmirror.io})
      end
    end
  end

  context 'registry' do
    let(:registry_address) do
      "#{registry_host}:#{registry_port}"
    end

    let(:registry_bad_address) do
      "#{registry_host}:5001"
    end

    it 'is able to run registry' do
      pp = <<-MANIFEST
        class { 'docker': #{docker_arg}}
        docker::run { 'registry':
          image         => '#{docker_registry_image}',
          pull_on_start => true,
          restart       => 'always',
          net           => '#{docker_network}',
          ports         => '#{registry_port}:#{registry_port}',
        }
        MANIFEST
      retry_on_error_matching(60, 5, %r{connection failure running}) do
        apply_manifest(pp, catch_failures: true)
      end
      # avoid a race condition with the registry taking time to start
      # on some operating systems
      sleep 10
    end

    it 'is able to login to the registry', retry: 3, retry_wait: 10 do
      pp = <<-MANIFEST
        docker::registry { '#{registry_address}':
          username => 'username',
          password => 'password',
        }
      MANIFEST
      apply_manifest(pp, catch_failures: true)
      shell("grep #{registry_address} #{config_file}", acceptable_exit_codes: [0])
      shell("test -e \"#{root_dir}/registry-auth-puppet_receipt_#{server_strip}_root\"", acceptable_exit_codes: [0])
    end

    it 'is able to logout from the registry' do
      pp = <<-MANIFEST
        docker::registry { '#{registry_address}':
          ensure=> absent,
        }
      MANIFEST
      apply_manifest(pp, catch_failures: true)
      shell("grep #{registry_address} #{config_file}", acceptable_exit_codes: [1, 2])
    end

    it 'does not create receipt if registry login fails' do
      pp = <<-MANIFEST
        docker::registry { '#{registry_bad_address}':
          username => 'username',
          password => 'password',
        }
      MANIFEST
      apply_manifest(pp, catch_failures: true)
      shell("grep #{registry_bad_address} #{config_file}", acceptable_exit_codes: [1, 2])
      shell("test -e \"#{root_dir}/registry-auth-puppet_receipt_#{bad_server_strip}_root\"", acceptable_exit_codes: [1])
    end
  end
end
