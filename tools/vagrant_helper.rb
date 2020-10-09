# -*- mode: ruby -*-
# vi: set ft=ruby :

raise "VAGRANT_HOME needs to be defined prior vagrant_helper!" unless defined? VAGRANT_HOME

VAGRANTFILE_API_VERSION = "2" unless defined? VAGRANTFILE_API_VERSION
VAGRANT_REQUIRED_VERSION = "1.8.0" unless defined? VAGRANT_REQUIRED_VERSION
VAGRANT_REQUIRED_LINKED_CLONE_VERSION = "1.8.4" unless defined? VAGRANT_REQUIRED_LINKED_CLONE_VERSION
VAGRANT_REQUIRED_QEMU_USE_SESSION_VERSION = "2.2.0" unless defined? VAGRANT_REQUIRED_QEMU_USE_SESSION_VERSION

# Require 1.6.5 at least
if ! defined? Vagrant.require_version
  if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(VAGRANT_REQUIRED_VERSION)
    puts "Vagrant >= " + VAGRANT_REQUIRED_VERSION + " required. Your version is " + Vagrant::VERSION
    exit 1
  end
else
  Vagrant.require_version ">= " + VAGRANT_REQUIRED_VERSION
end

nodesFile = VAGRANT_HOME + "/Vagrantfile.nodes"
localFile = VAGRANT_HOME + "/Vagrantfile.local"
nodes = {}

raise "ERROR: Vagrantfile.nodes is missing from source tree." unless File.exists?(nodesFile)

eval(IO.read(nodesFile), binding)

# allow to override the configuration
eval(IO.read(localFile), binding) if File.exists?(localFile)

# Export nodes to global scope
$nodes = nodes

## provider helper functions
def config_main(node_config, name, options)
  node_config.vm.hostname = name + "." + options[:net]
  node_config.vm.box_url = options[:url] if options[:url]
  if options[:forwarded]
    options[:forwarded].each_pair do |guest, local|
      node_config.vm.network "forwarded_port", guest: guest, host: local, auto_correct: true
    end
  end

  if options[:synced_folders]
    options[:synced_folders].each_pair do |source, target|
      node_config.vm.synced_folder source, target, nfs_udp: false
    end
  end

  node_config.vm.network :private_network, ip: options[:hostonly] if options[:hostonly]
end

def provider_parallels(node_config, name, options)
  node_config.vm.provider :parallels do |p, override|
    override.vm.box = options[:box_parallels]
    override.vm.boot_timeout = 600

    p.name = "Icinga 2: #{name.to_s}"
    p.update_guest_tools = false
    p.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_LINKED_CLONE_VERSION)

    # Set power consumption mode to "Better Performance"
    p.customize ["set", :id, "--longer-battery-life", "off"]

    p.memory = options[:memory] if options[:memory]
    p.cpus = options[:cpus] if options[:cpus]
  end
end

def provider_virtualbox(node_config, name, options)
  node_config.vm.provider :virtualbox do |vb, override|
    override.vm.box = options[:box_virtualbox]

    if Vagrant.has_plugin?("vagrant-vbguest")
      node_config.vbguest.auto_update = false
    end
    vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_LINKED_CLONE_VERSION)
    vb.name = name
    vb.gui = options[:gui] if options[:gui]
    vb.customize ["modifyvm", :id,
      "--groups", "/Icinga Vagrant/" + options[:net],
      "--memory", "512",
      "--cpus", "1",
      "--audio", "none",
      "--usb", "on",
      "--usbehci", "off",
      "--natdnshostresolver1", "on"
    ]
    vb.memory = options[:memory] if options[:memory]
    vb.cpus = options[:cpus] if options[:cpus]
  end
end

def provider_vmware(node_config, name, options)
  node_config.vm.provider :vmware_workstation do |vw, override|
     override.vm.box = options[:box_vmware]
     vw.memory = options[:memory] if options[:memory]
     vw.cpus = options[:cpus] if options[:cpus]
  end
end

def provider_libvirt(node_config, name, options)
  node_config.vm.provider :libvirt do |lv, override|
    override.vm.box = options[:box_libvirt]
    lv.memory = options[:memory] if options[:memory]
    lv.cpus = options[:cpus] if options[:cpus]
    lv.qemu_use_session = false if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new(VAGRANT_REQUIRED_QEMU_USE_SESSION_VERSION)
  end
end

def provider_hyperv(node_config, name, options)
  node_config.vm.provider :hyperv do |hv, override|
    override.vm.box = options[:box_hyperv]
    hv.memory = options[:memory] if options[:memory]
    hv.cpus = options[:cpus] if options[:cpus]
  end
end

def provider_openstack(node_config, name, options)
  node_config.vm.provider :openstack do |os, override|
    override.ssh.username  = "#{ENV['OS_SSH_USER']}"
    override.ssh.private_key_path = "#{ENV['OS_SSH_PRIVATE_KEY_PATH']}"
    os.meta_args_support      = true
    os.openstack_auth_url     = "#{ENV['OS_AUTH_URL']}"
    os.username               = "#{ENV['OS_USERNAME']}"
    os.password               = "#{ENV['OS_PASSWORD']}"
    os.flavor                 = "#{ENV['OS_FLAVOR']}"
    os.image                  = "#{ENV['OS_IMAGE']}"
    os.project_name           = "#{ENV['OS_PROJECT_NAME']}"
    os.keypair_name           = "#{ENV['OS_KEYPAIR_NAME']}"
    os.networks               = [ "#{ENV['OS_PROJECT_NAME']}" ]
    os.floating_ip_pool       = "#{ENV['OS_INTERFACE']}"
    os.security_groups        = [ 'default', 'vagrant' ] # how to Vagrant escape
    os.identity_api_version   = "#{ENV['OS_IDENTITY_API_VERSION']}"
    os.domain_name            = "#{ENV['OS_USER_DOMAIN_NAME']}"

    # since Vagrant 2.0, sync folder type is SMB on macOS, force it back.
    override.vm.allowed_synced_folder_types = :rsync

    override.vm.provision "shell", inline: 'echo "For Openstack provisioned hosts navigate to http://$1"', args: ['@@ssh_ip@@']
  end
end

def provision_pre(node_config, name, options)
  # provisioner: ensure that hostonly network is up
  # TODO: Remove.
  # workaround for Vagrant >1.8.4-1.9.1 not bringing up eth1 properly
  # https://github.com/mitchellh/vagrant/issues/8096
  node_config.vm.provision "shell", inline: "service network restart", run: "always"
end

def provision_puppet(node_config, name, options)
  # provisioner: install requirements
  node_config.vm.provision :shell, :path => "../.puppet/scripts/shell_provisioner_pre.sh"

  # sync generic hiera data
  node_config.vm.synced_folder "../.puppet/hieradata", "/hieradata", nfs_udp: false

  # provisioner: prepare Puppet. This is needed for Openstack with node::ipaddress initialized to the assigned floating ip.
  node_config.vm.provision :shell, :path => "../.puppet/scripts/shell_provisioner_pre_puppet.sh", :args => ['@@ssh_ip@@']

  # provisioner: install box using puppet manifest
  node_config.vm.provision :puppet do |puppet|
    puppet.hiera_config_path = "../.puppet/hieradata/hiera.yaml"
    puppet.module_path = "../.puppet/modules"
    puppet.environment_path = "environments"
    puppet.environment = "vagrant"
    puppet.options = "--disable_warnings=deprecations"
    #puppet.options = "--show_diff --disable_warnings=deprecations --verbose --debug"
  end
end

def provision_post(node_config, name, options)
  # provisioner: post script
  node_config.vm.provision :shell, :path => "../.puppet/scripts/shell_provisioner_post.sh", run: "always"

  # print a friendly message
  node_config.vm.provision "shell", inline: <<-SHELL
    echo "Finished installing the Vagrant box '#{name}'."
    echo "Navigate to http://#{options[:hostonly]}"
  SHELL
end

def config_hostmanager(config)
      return unless Vagrant.has_plugin?('vagrant-hostmanager')

      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.manage_guest = false
      config.hostmanager.ignore_private_ip = false
      config.hostmanager.include_offline = true
end
