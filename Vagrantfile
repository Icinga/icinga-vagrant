# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  #config.vm.define 'master' do |machine|
  #  machine.vm.box = 'box-cutter/ubuntu1404'
  #  machine.vm.network 'private_network', ip: '10.10.0.10'
  #  machine.vm.provision 'shell', :path => 'vagrant/provision-master.sh'
  #end

  config.vm.define 'ubuntu1404' do |machine|
    machine.vm.box = 'box-cutter/ubuntu1404'
    machine.vm.network 'private_network', ip: '10.10.0.11'
    machine.vm.network "forwarded_port", guest: 9000, host: 9011

    machine.vm.provision 'shell' do |shell|
      shell.path = 'development/vagrant/provision-client.sh'
      shell.args = ['apt']
    end
  end

  #config.vm.define 'ubuntu1204' do |machine|
  #  machine.vm.box = 'box-cutter/ubuntu1204'
  #  machine.vm.network 'private_network', ip: '10.10.0.12'
  #  machine.vm.network "forwarded_port", guest: 9000, host: 9012
  #
  #  machine.vm.provision 'shell' do |shell|
  #    shell.path = 'development/vagrant/provision-client.sh'
  #    shell.args = ['apt']
  #  end
  #end

  config.vm.define 'debian7' do |machine|
    machine.vm.box = 'box-cutter/debian75'
    machine.vm.network 'private_network', ip: '10.10.0.13'
    machine.vm.network "forwarded_port", guest: 9000, host: 9013

    machine.vm.provision 'shell' do |shell|
      shell.path = 'development/vagrant/provision-client.sh'
      shell.args = ['apt']
    end
  end

  config.vm.define 'centos6' do |machine|
    machine.vm.box = 'box-cutter/centos65'
    machine.vm.network 'private_network', ip: '10.10.0.14'
    machine.vm.network "forwarded_port", guest: 9000, host: 9014

    machine.vm.provision 'shell' do |shell|
      shell.path = 'development/vagrant/provision-client.sh'
      shell.args = ['yum']
    end
  end

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end
end
