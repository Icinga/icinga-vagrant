# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  debian_script = <<-SCRIPT
  # Fix issue with puppetlabs key (probably because of the old vagrant box)
  (cd /tmp && wget https://apt.puppetlabs.com/pubkey.gpg && apt-key add pubkey.gpg)

  apt-get update
  SCRIPT

  debian_systemd_script = <<-SCRIPT
  # To make init.d jobs work with systemd
  apt-get install -y init-system-helpers
  SCRIPT

  # Using a custom shell provisioner to run Puppet because the vagrant puppet
  # provisioner does not work for me...
  common_script = <<-SCRIPT
  ln -sf /vagrant /etc/puppetlabs/code/environments/production/modules/graylog

  # Required to run graylog::allinone
  test -d /etc/puppetlabs/code/environments/production/modules/apt || puppet module install puppetlabs-apt
  test -d /etc/puppetlabs/code/environments/production/modules/java || puppet module install puppetlabs-java
  test -d /etc/puppetlabs/code/environments/production/modules/mongodb || puppet module install puppet-mongodb
  test -d /etc/puppetlabs/code/environments/production/modules/elasticsearch || puppet module install elastic-elasticsearch

  cp /home/vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests/

  puppet apply --show_diff /etc/puppetlabs/code/environments/production/manifests/site.pp
  SCRIPT

  config.vm.provision 'file', source: 'tests/vagrant.pp',
                              destination: '/home/vagrant/site.pp'

  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.box = 'puppetlabs/ubuntu-14.04-64-puppet'
    machine.vm.network 'private_network', ip: '10.10.0.11'
    machine.vm.network "forwarded_port", guest: 9000, host: 9000
    machine.vm.network "forwarded_port", guest: 12900, host: 12900

    machine.vm.provision 'debian', type: 'shell', inline: debian_script
    machine.vm.provision 'common', type: 'shell', inline: common_script
  end

  config.vm.define 'ubuntu1604' do |machine|
    machine.vm.box = 'puppetlabs/ubuntu-16.04-64-puppet'
    machine.vm.network 'private_network', ip: '10.10.0.11'
    machine.vm.network "forwarded_port", guest: 9000, host: 9000
    machine.vm.network "forwarded_port", guest: 12900, host: 12900

    machine.vm.provision 'debian', type: 'shell', inline: debian_script
    machine.vm.provision 'debian-systemd', type: 'shell', inline: debian_systemd_script
    machine.vm.provision 'common', type: 'shell', inline: common_script
  end

  config.vm.define 'centos7' do |machine|
    machine.vm.box = 'puppetlabs/centos-7.2-64-puppet'
    machine.vm.network 'private_network', ip: '10.10.0.11'
    machine.vm.network "forwarded_port", guest: 9000, host: 9000
    machine.vm.network "forwarded_port", guest: 12900, host: 12900

    machine.vm.provision 'common', type: 'shell', inline: common_script
  end

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end
end
