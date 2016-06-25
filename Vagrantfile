# This Vagrant file is provided as a convenience for development and
# exploratory testing of puppet-logstash. It's not used by the formal
# testing framwork, it's just for hacking.
#
# See `CONTRIBUTING.md` for details on formal testing.
module_root = '/etc/puppetlabs/code/environments/production/modules/logstash'

Vagrant.configure(2) do |config|
  config.vm.box = 'puppetlabs/debian-8.2-64-puppet'
  config.vm.provider 'virtualbox' do |vm|
    vm.memory = 3 * 1024
  end

  # Make the Logstash module available.
  %w(manifests templates files).each do |dir|
    config.vm.synced_folder(dir, "#{module_root}/#{dir}")
  end

  # Prepare a puppetserver install so we can test the module in a realistic
  # way. 'puppet apply' is cool, but in reality, most people need this to work
  # in a master/agent configuration.
  config.vm.provision('shell', path: 'Vagrantfile.d/server.sh')
end
