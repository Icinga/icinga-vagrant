OpenStack provider usage
========================

Tested with an OpenStack Newton installation that uses Neutron for networking.

https://github.com/ggiamarchi/vagrant-openstack-provider

Login to your OpenStack and:
 - fetch the openrc v3 file
 - configure security groups (ICMP to&from anywhere and TCP 22, 80, 443 from your workstation/clients should be enough)

<pre>
source project-openrc.sh
export OS_SSH_USER="cloud-user"
export OS_KEYPAIR_NAME="Johans"
export OS_FLAVOR=standard.medium
export OS_IMAGE="CentOS-7"
$EDITOR Vagrantfile and add the security groups you created earlier to os.security_groups
vagrant up --provider=openstack
</pre>
