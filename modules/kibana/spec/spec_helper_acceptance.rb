require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'infrataster/rspec'
require 'rspec/retry'

ENV['PUPPET_INSTALL_TYPE'] = 'agent' if ENV['PUPPET_INSTALL_TYPE'].nil?

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

# Define server names for API tests
Infrataster::Server.define(:docker) do |server|
  server.address = default_node[:ip]
  server.ssh = default_node[:ssh].tap { |s| s.delete :forward_agent }
end
Infrataster::Server.define(:container) do |server|
  server.address = default_node[:vm_ip] # this gets ignored anyway
  server.from = :docker
end

RSpec.configure do |c|
  # Project root
  # proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    %w(kibana stdlib).tap do |modules|
      case fact('osfamily')
      when 'Debian'
        modules << 'apt'
      end
    end.each do |mod|
      install_dev_puppet_module(
        :module_name => mod,
        :source      => "spec/fixtures/modules/#{mod}"
      )
    end
  end

  c.around :each, :api do |example|
    example.run_with_retry retry: 3
  end
end
