[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-docker.svg?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-docker)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/puppetlabs/docker.svg)](https://forge.puppetlabs.com/puppetlabs/docker)

# Docker

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
   * [Proxy on Windows](#proxy-on-windows)
   * [Validating and unit testing the module](#validating-and-unit-testing-the-module)
3. [Usage - Configuration options and additional functionality](#usage)
   * [Images](#images)
   * [Containers](#containers)
   * [Networks](#networks)
   * [Volumes](#volumes)
   * [Compose](#compose)
   * [Machine](#machine)
   * [Swarm mode](#swarm-mode)
   * [Tasks](#tasks)
   * [Docker services](#docker-services)
   * [Private registries](#private-registries)
   * [Exec](#exec)
   * [Plugins](#plugins)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Description

The Puppet docker module installs, configures, and manages [Docker](https://github.com/docker/docker) from the [Docker repository](https://docs.docker.com/installation/). It supports the latest [Docker CE (Community Edition)](https://www.docker.com/community-edition) for Linux based distributions and [Docker EE(Enterprise Edition)](https://www.docker.com/enterprise-edition) for Windows and Linux as well as legacy releases.

Due to the new naming convention for Docker packages, this module prefaces any params that refer to the release with `_ce` or `_engine`. Examples of these are documented in this README.

## Setup

To create the Docker hosted repository and install the Docker package, add a single class to the manifest file:

```puppet
include 'docker'
```

To configure package sources independently and disable automatically including sources, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
}
```

The latest Docker [repositories](https://docs.docker.com/engine/installation/linux/docker-ce/debian/#set-up-the-repository) are now the default repositories for version 17.06 and above. If you are using an older version, the repositories are still configured based on the version number passed into the module.

To ensure the module configures the latest repositories, add the following code to the manifest file:

```puppet
class { 'docker':
  version => '17.09.0~ce-0~debian',
}
```

Using a version prior to 17.06, configures and installs from the old repositories:

```puppet
class { 'docker':
  version => '1.12.0-0~wheezy',
}
```

Docker provides a enterprise addition of the [Docker Engine](https://www.docker.com/enterprise-edition), called Docker EE. To install Docker EE on Debian systems, add the following code to the manifest file:

```puppet
class { 'docker':
  docker_ee => true,
  docker_ee_source_location => 'https://<docker_ee_repo_url>',
  docker_ee_key_source => 'https://<docker_ee_key_source_url>',
  docker_ee_key_id => '<key id>',
}
```

To install Docker EE on RHEL/CentOS:

```puppet
class { 'docker':
  docker_ee => true,
  docker_ee_source_location => 'https://<docker_ee_repo_url>',
  docker_ee_key_source => 'https://<docker_ee_key_source_url>',
}
```

For CentOS distributions, the docker module requires packages from the extras repository which is enabled by default on CentOS. For more information, see the official [CentOS documentation](https://wiki.centos.org/AdditionalResources/Repositories) and the official [Docker documentation](https://docs.docker.com/install/linux/docker-ce/centos/).

For Red Hat Enterprise Linux (RHEL) based distributions, the docker module uses the upstream repositories. To continue using the legacy distribution packages in the CentOS extras repository, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
  service_overrides_template  => false,
  docker_ce_package_name      => 'docker',
}
```

To use the CE packages, add the following code to the manifest file:

```puppet
class { 'docker':
  use_upstream_package_source => false,
  repo_opt => '',
}
```

By default, the Docker daemon binds to a unix socket at `/var/run/docker.sock`. To change this parameter and update the binding parameter to a tcp socket, add the following code to the manifest file:

```puppet
class { 'docker':
  tcp_bind        => ['tcp://127.0.0.1:2375'],
  socket_bind     => 'unix:///var/run/docker.sock',
  ip_forward      => true,
  iptables        => true,
  ip_masq         => true,
  bip             => '192.168.1.1/24',
  fixed_cidr      => '192.168.1.144/28',
}
```

For more information about the configuration options for the default docker bridge, see the [Docker documentation](https://docs.docker.com/v17.09/engine/userguide/networking/default_network/custom-docker0/).

The default group ownership of the Unix control socket differs based on OS. For example, on RHEL using docker-ce packages >=18.09.1, the socket file used by /usr/lib/systemd/system/docker.socket is owned by the docker group.  To override this value in /etc/sysconfig/docker and docker.socket (e.g. to use the 'root' group):

```puppet
class {'docker':
  socket_group => 'root',
  socket_override => true,
}
```

The socket_group parameter also takes a boolean for legacy cases where setting -G in /etc/sysconfig/docker is not desired:

```puppet
docker::socket_group: false
```

To add another service to the After= line in the [Unit] section of the systemd /etc/systemd/system/service-overrides.conf file, use the service_after_override parameter:

```puppet
docker::service_after_override: containerd.service
```

When setting up TLS, upload the related files (CA certificate, server certificate, and key) and include their paths in the manifest file:

```puppet
class { 'docker':
  tcp_bind        => ['tcp://0.0.0.0:2376'],
  tls_enable      => true,
  tls_cacert      => '/etc/docker/tls/ca.pem',
  tls_cert        => '/etc/docker/tls/cert.pem',
  tls_key         => '/etc/docker/tls/key.pem',
}
```

To specify which Docker rpm package to install, add the following code to the manifest file:

```puppet
class { 'docker':
  manage_package              => true,
  use_upstream_package_source => false,
  package_engine_name         => 'docker-engine'
  package_source_location     => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
  prerequired_packages        => [ 'glibc.i686', 'glibc.x86_64', 'sqlite.i686', 'sqlite.x86_64', 'device-mapper', 'device-mapper-libs', 'device-mapper-event-libs', 'device-mapper-event' ]
}
```

To track the latest version of Docker, add the following code to the manifest file:

```puppet
class { 'docker':
  version => 'latest',
}
```

To install docker from a test or edge channel, add the following code to the manifest file:

```puppet
class { 'docker':
  docker_ce_channel => 'test'
}
```

To allocate a dns server to the Docker daemon, add the following code to the manifest file:

```puppet
class { 'docker':
  dns => '8.8.8.8',
}
```

To add users to the Docker group, add the following array to the manifest file:

```puppet
class { 'docker':
  docker_users => ['user1', 'user2'],
}
```

To add daemon labels, add the following array to the manifest file:

```puppet
class { 'docker':
  labels => ['storage=ssd','stage=production'],
}
```

To pass additional parameters to the daemon, add `extra_parameters` to the manifest file:

```puppet
class { 'docker':
  extra_parameters => ['--experimental=true', '--metrics-addr=localhost:9323'],
```

To uninstall docker, add the following to the manifest file:

```puppet
class { 'docker':
  ensure => absent
}
```

Only Docker EE is supported on Windows. To install docker on Windows 2016 and above the `docker_ee` parameter must be specified:

```puppet
class { 'docker':
  docker_ee => true
}
```

### Proxy on Windows

To use docker through a proxy on Windows, a System Environment Variable HTTP_PROXY/HTTPS_PROXY must be set. See [Docker Engine on Windows](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon#proxy-configuration)
This can be done using a different puppet module such as the puppet-windows_env module. After setting the variable, the docker service must be restarted.

```puppet
windows_env { 'HTTP_PROXY'
  value  => 'http://1.2.3.4:80',
  notify => Service['docker'],
}
windows_env { 'HTTPS_PROXY'
  value  => 'http://1.2.3.4:80',
  notify => Service['docker'],
}
service { 'docker'
  ensure => 'running',
}
````

### Validating and unit testing the module

This module is compliant with the Puppet Development Kit [(PDK)](https://puppet.com/docs/pdk/1.x/pdk.html), which provides tools to help run unit tests on the module and validate the modules's metadata, syntax, and style.

To run all validations against this module, run the following command:

```
pdk validate
```

To change validation behavior, add options flags to the command. For a complete list of command options and usage information, see the PDK command [reference](https://puppet.com/docs/pdk/1.x/pdk_reference.html#pdk-validate-command).

To unit test the module, run the following command:

```
pdk test unit
```

To change unit test behavior, add option flags to the command. For a complete list of command options and usage information, see the PDK command [reference](https://puppet.com/docs/pdk/1.x/pdk_reference.html#pdk-test-unit-command).

## Usage

### Images

Each image requires a unique name; otherwise, the installation fails when a duplicate name is detected.

To install a Docker image, add the `docker::image` defined type to the manifest file:

```puppet
docker::image { 'base': }
```

The code above is equivalent to running the `docker pull base` command. However, it removes the default five-minute execution timeout.

To include an optional parameter for installing image tags that is the equivalent to running `docker pull -t="precise" ubuntu`, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  image_tag => 'precise'
}
```

Including the `docker_file` parameter is equivalent to running the `docker build -t ubuntu - < /tmp/Dockerfile` command. To add or build an image from a dockerfile that includes the `docker_file` parameter, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_file => '/tmp/Dockerfile'
}
```

Including the `docker_dir` parameter is equivalent to running the `docker build -t ubuntu /tmp/ubuntu_image` command. To add or build an image from a dockerfile that includes the `docker_dir` parameter, add the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_dir => '/tmp/ubuntu_image'
}
```

To rebuild an image, subscribe to external events such as Dockerfile changes by adding the following code to the manifest file:

```puppet
docker::image { 'ubuntu':
  docker_file => '/tmp/Dockerfile'
  subscribe => File['/tmp/Dockerfile'],
}

file { '/tmp/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/someModule/Dockerfile',
}
```

To remove an image, add the following code to the manifest file:

```puppet
docker::image { 'base':
  ensure => 'absent'
}

docker::image { 'ubuntu':
  ensure    => 'absent',
  image_tag => 'precise'
}
```

To configure the `docker::images` class when using Hiera, add the following code to the manifest file:

```yaml
---
  classes:
    - docker::images

docker::images::images:
  ubuntu:
    image_tag: 'precise'
```

### Containers

To launch containers, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  image   => 'base',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

This is equivalent to running the  `docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"` command to launch a Docker container managed by the local init system.

`run` includes a number of optional parameters:

```puppet
docker::run { 'helloworld':
  image            => 'base',
  detach           => true,
  service_prefix   => 'docker-',
  command          => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  ports            => ['4444', '4555'],
  expose           => ['4666', '4777'],
  links            => ['mysql:db'],
  net              => ['my-user-def-net','my-user-def-net-2'],
  disable_network  => false,
  volumes          => ['/var/lib/couchdb', '/var/log'],
  volumes_from     => '6446ea52fbc9',
  memory_limit     => '10m', # (format: '<number><unit>', where unit = b, k, m or g)
  cpuset           => ['0', '3'],
  username         => 'example',
  hostname         => 'example.com',
  env              => ['FOO=BAR', 'FOO2=BAR2'],
  env_file         => ['/etc/foo', '/etc/bar'],
  labels           => ['com.example.foo="true"', 'com.example.bar="false"'],
  dns              => ['8.8.8.8', '8.8.4.4'],
  restart_service  => true,
  privileged       => false,
  pull_on_start    => false,
  before_stop      => 'echo "So Long, and Thanks for All the Fish"',
  before_start     => 'echo "Run this on the host before starting the Docker container"',
  after            => [ 'container_b', 'mysql' ],
  depends          => [ 'container_a', 'postgres' ],
  stop_wait_time   => 0,
  read_only        => false,
  extra_parameters => [ '--restart=always' ],
}
```

You can specify the `ports`, `expose`, `env`, `dns`, and `volumes` values with a single string or an array.

To pull the image before it starts, specify the `pull_on_start` parameter.

Use the `detach` param to run container a container without the `-a` flag. This is only required on systems without `systemd`. This default is set in the params.pp based on the OS. Only override if you understand the consuquences and have a specific use case.

To execute a command before the container stops, specify the `before_stop` parameter.

Adding the container name to the `after` parameter to specify which containers start first, affects the generation of the `init.d/systemd` script.

Add container dependencies to the `depends` parameter. The container starts before this container and stops before the depended container. This affects the generation of the `init.d/systemd` script. Use the `depend_services` parameter to specify dependencies for general services, which are not Docker related, that start before this container.

The `extra_parameters` parameter, which contains an array of command line arguments to pass to the `docker run` command, is useful for adding additional or experimental options that the docker module currently does not support.

By default, automatic restarting of the service on failure is enabled by the service file for systemd based systems.

It's recommended that an image tag is used at all times with the `docker::run` define type. If not, the latest image is used whether it's in a remote registry or installed on the server already by the `docker::image` define type.

NOTE: As of v3.0.0, if the latest tag is used the image will be the latest at the time the of the initial puppet run. Any subsequent puppet runs will always reference the latest local image. Therefore, it's recommended that an alternative tag be used, or the image be removed before pulling latest again.

To use an image tag, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

By default, when the service stops or starts, the generated init scripts remove the container, but not the associated volumes. To change this behaviour, add the following code to the manifest file:

```puppet
docker::run { 'helloworld':
  remove_container_on_start => true,
  remove_volume_on_start    => false,
  remove_container_on_stop  => true,
  remove_volume_on_stop     => false,
}
```

If using Hiera, you can configure the `docker::run_instance` class:

```yaml
---
  classes:
    - docker::run_instance

  docker::run_instance::instance:
    helloworld:
      image: 'ubuntu:precise'
      command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'
```

To remove a running container, add the following code to the manifest file. This also removes the systemd service file associated with the container.

```puppet
docker::run { 'helloworld':
  ensure => absent,
}
```

To enable the restart of an unhealthy container, add the following code to the manifest file. In order to set the health check interval time set the optional health_check_interval parameter, the default health check interval is 30 seconds.

```puppet
docker::run { 'helloworld':
  image => 'base',
  command => 'command',
  health_check_cmd => '<command_to_execute_to_check_your_containers_health>',
  restart_on_unhealthy => true,
  health_check_interval => '<time between running docker healthcheck>',
```

To run command on Windows 2016 requires the `restart` parameter to be set:

```puppet
docker::run { 'helloworld':
  image => 'microsoft/nanoserver',
  command => 'ping 127.0.0.1 -t',
  restart => 'always'
```

### Networks

Docker 1.9.x supports networks. To expose the `docker_network` type that is used to manage networks, add the following code to the manifest file:

```puppet
docker_network { 'my-net':
  ensure   => present,
  driver   => 'overlay',
  subnet   => '192.168.1.0/24',
  gateway  => '192.168.1.1',
  ip_range => '192.168.1.4/32',
}
```

The name value and the `ensure` parameter are required. If you do not include the `driver` value, the default bridge is used. The Docker daemon must be configured for some networks and configuring the cluster store for the overlay network would be an example.

To configure the cluster store, update the `docker` class in the manifest file:

```puppet
extra_parameters => '--cluster-store=<backend>://172.17.8.101:<port> --cluster-advertise=<interface>:2376'
```

If using Hiera, configure the `docker::networks` class in the manifest file:

```yaml
---
  classes:
    - docker::networks

docker::networks::networks:
  local-docker:
    ensure: 'present'
    subnet: '192.168.1.0/24'
    gateway: '192.168.1.1'
```

A defined network can be used on a `docker::run` resource with the `net` parameter.

#### Windows

On windows, only one NAT network is supported. To support multiple networks, Windows Server 2016 with KB4015217 is required. See [Windows Container Network Drivers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/network-drivers-topologies) and [Windows Container Networking](https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/architecture).

The Docker daemon will create a default NAT network on the first start unless specified otherwise. To disable the network creation, use the parameter `bridge => 'none'` when installing docker.

### Volumes

Docker 1.9.x added support for volumes. These are *NOT* to be confused with the legacy volumes, now known as `bind mounts`. To expose the `docker_volume` type, which is used to manage volumes, add the following code to the manifest file:

```puppet
docker_volume { 'my-volume':
  ensure => present,
}
```

You can pass additional mount options to the `local` driver. For mounting an NFS export, use:

```puppet
docker_volume { 'nfs-volume':
  ensure  => present,
  driver  => 'local',
  options => {
    type   => 'nfs4',
    o      => 'addr=10.10.10.10,rw',
    device => ':/exports/data'
  },
}
```

The name value and the `ensure` parameter are required. If you do not include the `driver` value, the default `local` is used.

If using Hiera, configure the `docker::volumes` class in the manifest file:

```yaml
---
  classes:
    - docker::volumes

docker::volumes:
  blueocean:
    ensure: present
    driver: local
    options:
      type: "nfs"
      o: "addr=%{custom_manager},rw",
      device: ":/srv/blueocean"
```

Available parameters for `options` depend on the used volume driver. For details, see
[Using volumes](https://docs.docker.com/storage/volumes/) from the Docker manual.

Some of the key advantages for using `volumes` over `bind mounts` are:

* Easier to back up or migrate rather than `bind mounts` (legacy volumes).
* Managed with Docker CLI or API (Puppet type uses the CLI commands).
* Works on Windows and Linux.
* Easily shared between containers.
* Allows for store volumes on remote hosts or cloud providers.
* Encrypt contents of volumes.
* Add other functionality
* New volume's contents can be pre-populated by a container.

When using the `volumes` array with `docker::run`, the command on the backend will know if it needs to use `bind mounts` or `volumes` based off the data passed to the `-v` option.

Running `docker::run` with native volumes:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  volumes => ['my-volume:/var/log'],
}
```

### Compose

Docker Compose describes a set of containers in YAML format and runs a command to build and run those containers. Included in the docker module is the `docker_compose` type. This enables Puppet to run Compose and remediate any issues to ensure reality matches the model in your Compose file.

Before you use the `docker_compose` type, you must install the Docker Compose utility.

To install Docker Compose, add the following code to the manifest file:

```puppet
class {'docker::compose':
  ensure => present,
  version => '1.9.0',
}
```

Set the `version` parameter to any version you need to install.

This is an example of a Compose file:

```yaml
compose_test:
  image: ubuntu:14.04
  command: /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

Specify the `file` resource to add a Compose file to the machine you have Puppet running on. To define a `docker_compose` resource pointing to the Compose file, add the following code to the manifest file:

```puppet
docker_compose { 'test':
  compose_files => ['/tmp/docker-compose.yml'],
  ensure  => present,
}
```

Puppet automatically runs Compose, because the relevant Compose services aren't running. If required, include additional options such as enabling experimental features and scaling rules.

In the example below, Puppet runs Compose when the number of containers specified for a service doesn't match the scale values.

```puppet
docker_compose { 'test':
  compose_files => ['/tmp/docker-compose.yml'],
  ensure  => present,
  scale   => {
    'compose_test' => 2,
  },
  options => '--x-networking'
}
```

Give options to the ```docker-compose up``` command, such as ```--remove-orphans```, by using the ```up_args``` option.

To supply multiple overide compose files add the following to the manifest file:

```puppet
docker_compose {'test':
  compose_files => ['master-docker-compose.yml', 'override-compose.yml'],
}
```

Please note you should supply your master docker-compose file as the first element in the array. As per docker, multi compose file support compose files are merged in the order they are specified in the array.

If you are using a v3.2 compose file or above on a Docker Swarm cluster, use the `docker::stack` class. Include the file resource before you run the stack command.

NOTE: this define will be deprecated in a future release in favor of the [docker stack type](REFERENCE.md#docker_stack)

To deploy the stack, add the following code to the manifest file:

```puppet
 docker::stack { 'yourapp':
   ensure  => present,
   stack_name => 'yourapp',
   compose_files => ['/tmp/docker-compose.yaml'],
   require => [Class['docker'], File['/tmp/docker-compose.yaml']],
}
```

To remove the stack, set `ensure  => absent`.

If you are using a v3.2 compose file or above on a Docker Swarm cluster, include the `docker::stack` class. Similar to using older versions of Docker, compose the file resource before running the stack command.

To deploy the stack, add the following code to the manifest file.

```puppet
docker::stack { 'yourapp':
  ensure  => present,
  stack_name => 'yourapp',
  compose_files => ['/tmp/docker-compose.yaml'],
  with_registry_auth => true,
  require => [Class['docker'], File['/tmp/docker-compose.yaml']],
}
```

To use use the equivalent type and provier, use the following in your manfiest file. For more information on specific parameters see the [docker_stack type documentation](REFERENCE.md#docker_stack).
```puppet
docker_stack { 'test':
  compose_files => ['/tmp/docker-compose.yml'],
  ensure  => present,
  up_args => '--with-registry-auth',
}
```

To remove the stack, set `ensure  => absent`.

### Machine

You can use Docker Machine to install Docker Engine on virtual hosts, and manage the hosts with docker-machine commands. You can also use Machine to create Docker hosts on your local Mac or Windows box, on your company network, in your data center, or on cloud providers like Azure, AWS, or Digital Ocean.

For more information on machines, see the [Docker Machines](https://docs.docker.com/machine/) documentation.

This module only installs the Docker Machine utility.

To install Docker Machine, add the following code to the manifest file:

```puppet
class {'docker::machine':
  ensure => present,
  version => '1.16.1',
}
```

Set the `version` parameter to any version you need to install.

### Swarm mode

To natively manage a cluster of Docker Engines known as a swarm, Docker Engine 1.12 includes a swarm mode.

To cluster your Docker engines, use one of the following Puppet resources:

* [Swarm manager](#Swarm-manager)
* [Swarm worker](#Swarm-worker)

#### Windows

To configure swarm, Windows Server 2016 requires KB4015217 and the following firewall ports to be open on all nodes:

* TCP port 2377 for cluster management communications
* TCP and UDP port 7946 for communication among nodes
* UDP port 4789 for overlay network traffic

#### Swarm manager

To configure the swarm manager, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_manager':
  init           => true,
  advertise_addr => '192.168.1.1',
  listen_addr    => '192.168.1.1',
}
```

For a multihomed server and to enable cluster communications between the node, include the ```advertise_addr``` and ```listen_addr``` parameters.

#### Swarm worker

To configure the swarm worker, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_worker':
join           => true,
advertise_addr => '192.168.1.2',
listen_addr    => '192.168.1.2',
manager_ip     => '192.168.1.1',
token          => 'your_join_token'
}
```

To configure a worker node or a second manager, include the swarm manager IP address in the `manager_ip` parameter. To define the role of the node in the cluster, include the `token` parameter. When creating an additional swarm manager and a worker node, separate tokens are required.

To remove a node from a cluster, add the following code to the manifest file:

```puppet
docker::swarm {'cluster_worker':
ensure => absent
}
```

### Tasks

The docker module has an example task that allows a user to initialize, join and leave a swarm.

```puppet
bolt task run docker::swarm_init listen_addr=172.17.10.101 adverstise_addr=172.17.10.101 ---nodes swarm-master --user <user> --password <password> --modulepath <module_path>

docker swarm init --advertise-addr=172.17.10.101 --listen-addr=172.17.10.101
Swarm initialized: current node (w8syk0g286vd7d9kwzt7jl44z) is now a manager.
```

To add a worker to this swarm, run the following command:

```puppet
    docker swarm join --token SWMTKN-1-317gw63odq6w1foaw0xkibzqy34lga55aa5nbjlqekcrhg8utl-08vrg0913zken8h9vfo4t6k0t 172.17.10.101:2377
```

To add a manager to this swarm, run `docker swarm join-token manager` and follow the instructions.

```puppet
Ran on 1 node in 4.04 seconds
```

```puppet
bolt task run docker::swarm_token node_role=worker ---nodes swarm-master --user <user> --password <password> --modulepath <module_path>

SWMTKN-1-317gw63odq6w1foaw0xkibzqy34lga55aa5nbjlqekcrhg8utl-08vrg0913zken8h9vfo4t6k0t

Ran on 1 node in 4.02 seconds
```

```puppet
bolt task run docker::swarm_join listen_addr=172.17.10.102 adverstise_addr=172.17.10.102 token=<swarm_token> manager_ip=172.17.10.101:2377 --nodes swarm-02 --user root --password puppet --modulepath /tmp/modules

This node joined a swarm as a worker.

Ran on 1 node in 4.68 seconds
```

```puppet
bolt task run docker::swarm_leave --nodes swarm-02 --user root --password puppet --modulepath --modulepath <module_path>

Node left the swarm.

Ran on 1 node in 6.16 seconds
```

### Docker services

Docker services create distributed applications across multiple swarm nodes. Each Docker service replicates a set of containers across the swarm.

To create a Docker service, add the following code to the manifest file:

```puppet
docker::services {'redis':
    create => true,
    service_name => 'redis',
    image => 'redis:latest',
    publish => '6379:639',
    replicas => '5',
    mounts => ['type=bind,source=/etc/my-redis.conf,target=/etc/redis/redis.conf,readonly'],
    extra_params => ['--update-delay 1m', '--restart-window 30s'],
    command => ['redis-server', '--appendonly', 'yes'],
  }
```

To base the service off an image, include the `image` parameter and include the `publish` parameter to expose the service port (use an array to specify multiple published ports). To set the amount of containers running in the service, include the `replicas` parameter. To attach one or multiple filesystems to the service, use the `mounts` parameter. For information regarding the `extra_params` parameter, see `docker service create --help`. The `command` parameter can either be specified as an array or a string.

To update the service, add the following code to the manifest file:

```puppet
docker::services {'redis_update':
  create => false,
  update => true,
  service_name => 'redis',
  replicas => '3',
}
```

To update a service without creating a new one, include the the `update => true` parameter and the `create => false` parameter.

To scale a service, add the following code to the manifest file:

```puppet
docker::services {'redis_scale':
  create => false,
  scale => true,
  service_name => 'redis',
  replicas => '10',
}
```

To scale the service without creating a new one, include the the `scale => true` parameter and the `create => false` parameter. In the example above, the service is scaled to 10.

To remove a service, add the following code to the manifest file:

```puppet
docker::services {'redis':
  create => false,
  ensure => 'absent',
  service_name => 'redis',
}
```

To remove the service from a swarm, include the `ensure => absent` parameter and the `service_name` parameter.

### Private registries

When a server is not specified, images are pushed and pulled from [index.docker.io](https://index.docker.io). To qualify your image name, create a private repository without authentication.

To configure authentication for a private registry, add the following code to the manifest file, depending on what version of Docker you are running. If you are using Docker V1.10 or earlier, specify the docker version in the manifest file:

```puppet
docker::registry { 'example.docker.io:5000':
  username => 'user',
  password => 'secret',
  email    => 'user@example.com',
  version  => '<docker_version>'
}
```

To pull images from the docker store, use the following as the registry definition with your own docker hub credentials

```puppet
  docker::registry {'https://index.docker.io/v1/':
    username => 'username',
    password => 'password',
  }
```

If using hiera, configure the `docker::registry_auth` class:

```yaml
docker::registry_auth::registries:
  'example.docker.io:5000':
    username: 'user1'
    password: 'secret'
    email: 'user1@example.io'
    version: '<docker_version>'
```

If using Docker V1.11 or later, the docker login email flag has been deprecated. See the [docker_change_log](https://docs.docker.com/release-notes/docker-engine/#1110-2016-04-13).

Add the following code to the manifest file:

```puppet
docker::registry { 'example.docker.io:5000':
  username => 'user',
  password => 'secret',
}
```

If using hiera, configure the 'docker::registry_auth' class:

```yaml
docker::registry_auth::registries:
  'example.docker.io:5000':
    username: 'user1'
    password: 'secret'
```

To log out of a registry, add the following code to the manifest file:

```puppet
docker::registry { 'example.docker.io:5000':
  ensure => 'absent',
}
```

To set a preferred registry mirror, add the following code to the manifest file:

```puppet
class { 'docker':
  registry_mirror => 'http://testmirror.io'
}
```

### Exec

Within the context of a running container, the docker module supports arbitrary commands:

```puppet
docker::exec { 'cron_allow_root':
  detach       => true,
  container    => 'mycontainer',
  command      => '/bin/echo root >> /usr/lib/cron/cron.allow',
  onlyif       => 'running',
  tty          => true,
  env          => ['FOO=BAR', 'FOO2=BAR2'],
  unless       => 'grep root /usr/lib/cron/cron.allow 2>/dev/null',
  refreshonly  => true,
}
```

### Plugin

The module supports the installation of Docker plugins:

```puppet
docker::plugin {'foo/fooplugin:latest':
  settings => ['VAR1=test','VAR2=value']
}
```

To disable an active plugin:

```puppet
docker::plugin {'foo/fooplugin:latest':
  enabled => false,
}
```

To remove an active plugin:

```puppet
docker::plugin {'foo/fooplugin:latest'
  ensure => 'absent',
  force_remove => true,
}
```

## Reference

For information on classes, types and functions see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-docker/blob/master/REFERENCE.md).

## Limitations

This module supports:

* Centos 7.0
* Debian 8.0
* Debian 9.0
* RedHat 7.0
* Ubuntu 14.04
* Ubuntu 16.04
* Ubuntu 18.04
* Windows Server 2016 (Docker Enterprise Edition only)

## Development

If you would like to contribute to this module, see the guidelines in [CONTRIBUTING.MD](https://github.com/puppetlabs/puppetlabs-docker/blob/master/CONTRIBUTING.md).
