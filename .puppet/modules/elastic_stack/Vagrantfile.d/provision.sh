# Install and configure Puppet and Puppetserver.
export DEBIAN_FRONTEND=noninteractive

wget https://apt.puppetlabs.com/puppet6-release-xenial.deb
dpkg -i puppet6-release-xenial.deb
apt-get update
apt-get install -y apt-transport-https
apt-get install -y puppet-agent puppetserver

# REF: https://tickets.puppetlabs.com/browse/SERVER-528
service puppet stop
service puppetserver stop
rm -rf /etc/puppetlabs/puppet/ssl/private_keys/*
rm -rf /etc/puppetlabs/puppet/ssl/certs/*
echo 'autosign = true' >> /etc/puppetlabs/puppet/puppet.conf
service puppetserver start

# Puppet agent looks for the server called "puppet" by default.
# In this case, we want that to be us (the loopback address).
echo '127.0.0.1 localhost puppet vagrant' > /etc/hosts

# Install puppet-elastic-stack dependencies.
modules=(
  puppet-yum
  puppet-zypprepo
  puppetlabs-apt
  puppetlabs-yumrepo_core
)

for module in ${modules[@]}; do
  /opt/puppetlabs/bin/puppet module install \
  --target-dir=/etc/puppetlabs/code/environments/production/modules \
  ${module}
done
