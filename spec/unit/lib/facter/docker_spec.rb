require 'spec_helper'
require 'json'

describe 'Facter::Util::Fact' do
  before :each do
    Facter.clear
    if Facter.value(:kernel) == 'windows'
      docker_command = 'powershell -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -c docker'
      Facter::Util::Resolution.stubs(:which).with('docker').returns('C:\Program Files\Docker\docker.exe')
    else
      docker_command = 'docker'
      Facter::Util::Resolution.stubs(:which).with('docker').returns('/usr/bin/docker')
    end
    docker_info = File.read(fixtures('facts', 'docker_info'))
    Facter::Util::Resolution.stubs(:exec).with("#{docker_command} info --format '{{json .}}'").returns(docker_info)
    processors = File.read(fixtures('facts', 'processors'))
    Facter.fact(:processors).stubs(:value).returns(JSON.parse(processors))

    docker_network_list = File.read(fixtures('facts', 'docker_network_list'))
    Facter::Util::Resolution.stubs(:exec).with("#{docker_command} network ls | tail -n +2").returns(docker_network_list)
    docker_network_names = []
    docker_network_list.each_line { |line| docker_network_names.push line.split[1] }
    docker_network_names.each do |network|
      inspect = File.read(fixtures('facts', "docker_network_inspect_#{network}"))
      Facter::Util::Resolution.stubs(:exec).with("#{docker_command} network inspect #{network}").returns(inspect)
    end
  end
  after(:each) { Facter.clear }

  describe 'docker fact with composer network' do
    before :each do
      Facter.fact(:interfaces).stubs(:value).returns('br-c5810f1e3113,docker0,eth0,lo')
    end
    it do
      fact = File.read(fixtures('facts', 'facts_with_compose'))
      fact = JSON.parse(fact.to_json, quirks_mode: true)
      facts = eval(fact) # rubocop:disable Security/Eval
      expect(Facter.fact(:docker).value).to include(
        'network' => facts['network'],
      )
    end
  end

  describe 'docker fact without composer network' do
    before :each do
      Facter.fact(:interfaces).stubs(:value).returns('br-19a6ebf6f5a5,docker0,eth0,lo')
    end
    it do
      fact = File.read(fixtures('facts', 'facts_without_compose')).chomp
      fact_json = fact.to_json
      facts = JSON.parse(fact_json, quirks_mode: true)
      facts = eval(facts) # rubocop:disable Security/Eval

      expect(Facter.fact(:docker).value).to include(
        'network' => facts['network'],
      )
    end
  end

  describe 'docker client version' do
    before(:each) do
      docker_version = File.read(fixtures('facts', 'docker_version'))
      Facter.fact(:docker_version).stubs(:value).returns(JSON.parse(docker_version))
      Facter.fact(:interfaces).stubs(:value).returns('br-19a6ebf6f5a5,docker0,eth0,lo')
    end
    it do
      expect(Facter.fact(:docker_client_version).value).to eq(
        '17.03.1-ce-client',
      )
    end
  end

  describe 'docker server version' do
    before(:each) do
      docker_version = File.read(fixtures('facts', 'docker_version'))
      Facter.fact(:docker_version).stubs(:value).returns(JSON.parse(docker_version))
      Facter.fact(:interfaces).stubs(:value).returns('br-19a6ebf6f5a5,docker0,eth0,lo')
    end
    it do
      expect(Facter.fact(:docker_server_version).value).to eq(
        '17.03.1-ce-server',
      )
    end
  end

  describe 'docker info' do
    it 'has valid entries' do
      expect(Facter.fact(:docker).value).to include(
        'Architecture' => 'x86_64',
      )
    end
  end
end
