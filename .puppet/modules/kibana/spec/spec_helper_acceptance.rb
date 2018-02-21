require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'infrataster/rspec'
require 'rspec/retry'

require_relative 'spec_utilities'

ENV['PUPPET_INSTALL_TYPE'] = 'agent' if ENV['PUPPET_INSTALL_TYPE'].nil?

hosts.each do |host|
  # Set the host to 'aio' in order to adopt the puppet-agent style of
  # installation, and configure paths/etc.
  host[:type] = 'aio'
  configure_defaults_on host, 'aio'

  # Install Puppet
  #
  # We spawn a thread to print dots periodically while installing puppet to
  # avoid inactivity timeouts in Travis. Don't judge me.
  progress = Thread.new do
    print 'Installing puppet..'
    print '.' while sleep 5
  end

  case host.name
  when /debian-9/, /opensuse/
    # A few special cases need to be installed from gems (if the distro is
    # very new and has no puppet repo package or has no upstream packages).
    install_puppet_from_gem(
      host,
      version: Gem.loaded_specs['puppet'].version
    )
  else
    # Otherwise, just use the all-in-one agent package.
    install_puppet_agent_on(
      host,
      puppet_agent_version: to_agent_version(Gem.loaded_specs['puppet'].version)
    )
  end
  # Quit the print thread and include some debugging.
  progress.exit
  puts "done. Installed version #{shell('puppet --version').output}"

  # Define server names for API tests
  Infrataster::Server.define(:docker) do |server|
    server.address = host[:ip]
    server.ssh = host[:ssh].tap { |s| s.delete :forward_agent }
  end
  Infrataster::Server.define(:container) do |server|
    server.address = host[:vm_ip] # this gets ignored anyway
    server.from = :docker
  end
end

RSpec.configure do |c|
  # Project root
  # proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.add_setting :pkg_ext
  c.pkg_ext = case fact('osfamily')
              when 'Debian'
                'deb'
              when 'RedHat'
                'rpm'
              end

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    ['kibana', (['apt', 'stdlib'] if c.pkg_ext == 'deb')].flatten.compact.each do |mod|
      install_dev_puppet_module(
        :module_name => mod,
        :source      => "spec/fixtures/modules/#{mod}"
      )
    end

    # Copy over the snapshot package if we're running snapshot tests
    if c.files_to_run.any? { |fn| fn.include? 'snapshot' } and !c.pkg_ext.nil?
      filename = "kibana-snapshot.#{c.pkg_ext}"
      hosts.each do |host|
        scp_to host, artifact(filename), "/tmp/#{filename}"
      end
      c.add_setting :snapshot_version
      c.snapshot_version = File.readlink(artifact(filename)).match(/kibana-(?<v>.*)[.][a-z]+/)[:v]
    end
  end

  c.around :each, :api do |example|
    # The initial optimization startup time of Kibana is _incredibly_ slow,
    # so we need to be pretty generous with how we retry API call attempts.
    example.run_with_retry retry: 10, retry_wait: 5
  end
end
