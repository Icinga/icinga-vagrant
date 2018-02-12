# This Vagrant file is provided as a convenience for development and
# exploratory testing of puppet-elastic-stack. It's not used by the formal
# testing framwork, it's just for hacking.
#
module_root = '/etc/puppetlabs/code/environments/production/modules/elastic_stack'

Vagrant.configure(2) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 4*1024
    v.cpus = 4
  end

  # Make the module available.
  %w(manifests templates).each do |dir|
    config.vm.synced_folder(dir, "#{module_root}/#{dir}")
  end

  # Provision with Puppet and Puppetserver
  config.vm.provision('shell', path: 'Vagrantfile.d/provision.sh')
end
