require 'spec_helper_acceptance'

broken = false
command = 'docker'
plugin_name = 'vieux/sshfs'

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

describe 'docker plugin', win_broken: broken do
  before(:all) do
    install_code = "class { 'docker': #{docker_args}}"
    apply_manifest(install_code, catch_failures: true)
  end

  describe command("#{command} plugin --help") do
    its(:exit_status) { is_expected.to eq 0 }
  end

  context 'manage a plugin' do
    after(:all) do
      shell("#{command} plugin rm -f #{plugin_name}")
    end

    it 'is idempotent' do
      pp = <<-MANIFEST
        docker::plugin { '#{plugin_name}':}
      MANIFEST
      idempotent_apply(default, pp, {})
    end

    it 'has installed a plugin' do
      shell("#{command} plugin inspect #{plugin_name}", acceptable_exit_codes: [0])
    end
  end
end
