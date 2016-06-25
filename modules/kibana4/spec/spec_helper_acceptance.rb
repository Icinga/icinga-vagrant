require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet on host,
  install_puppet
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    #weirdly this installs in /etc/puppetlabs/puppet/modules which is why we are changing basemodulepath further down
    puppet_module_install(source: module_root, module_name: 'kibana4')
    hosts.each do |host|
      on host, puppet('module', 'install',
                      'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-java'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'elasticsearch-elasticsearch'), acceptable_exit_codes: [0, 1]
      on host, "puppet config set basemodulepath /etc/puppet/modules:/etc/puppetlabs/puppet/modules/", acceptable_exit_codes: [0, 1]
      pp = <<-EOS
        class { 'elasticsearch':
          manage_repo  => true,
          repo_version => '2.x',
          java_install => true,
        }
        elasticsearch::instance { 'es-01': }
      EOS
      apply_manifest_on(host, pp, :catch_failures => true)
    end
  end
end
