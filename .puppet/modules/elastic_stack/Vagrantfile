# This Vagrant file is provided as a convenience for development and
# exploratory testing of puppet-elastic-stack. It's not used by the formal
# testing framwork, it's just for hacking.
#
puppet_code_root = '/etc/puppetlabs/code/environments/production'
module_root = "#{puppet_code_root}/modules/elastic_stack"

Vagrant.configure(2) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 4 * 1024
    v.cpus = 4
  end

  # Make the module available.
  config.vm.synced_folder('manifests', "#{module_root}/manifests")

  # Map in a Puppet manifest that can be used for experiments.
  config.vm.synced_folder('Vagrantfile.d/manifests', "#{puppet_code_root}/manifests")

  # Provision with Puppet and Puppetserver
  config.vm.provision('shell', path: 'Vagrantfile.d/provision.sh')
end
