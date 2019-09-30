require 'beaker-rspec'
require 'beaker_spec_helper'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

include BeakerSpecHelper

# https://github.com/puppetlabs/beaker-puppet_install_helper
run_puppet_install_helper

UNSUPPORTED_PLATFORMS = %w(Suse windows AIX Solaris).freeze

BEAKER_LOG = '/tmp/beaker.log'.freeze

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = File.basename(proj_root.split('-').last)

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      File.open(BEAKER_LOG, 'w') do |fd|
        fd.write(JSON.pretty_generate(host.host_hash))
        fd.write("\n" + '-' * 80 + "\n")
        fd.write(JSON.pretty_generate(host.options))
      end

      if host['platform'] =~ %r{ubuntu}
        on host, puppet('resource package apt-transport-https ensure=installed')
      end

      on host, puppet('resource package git ensure=installed')
      on host, puppet('resource package net-tools ensure=installed')
      on host, puppet('resource package iproute ensure=installed')

      scp_to(host, "#{proj_root}/spec/fixtures/test_facter.sh", '/usr/bin/test_facter.sh')
      scp_to(host, "#{proj_root}/spec/fixtures/test_facter.rb", '/usr/bin/test_facter.rb')

      copy_module_to(host, source: proj_root, module_name: module_name)

      # https://github.com/camptocamp/beaker_spec_helper
      BeakerSpecHelper.spec_prep(host)
    end
  end
end
