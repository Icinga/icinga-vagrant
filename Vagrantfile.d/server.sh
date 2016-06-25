# Install and configure puppetserver.

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y puppetserver

# REF: https://tickets.puppetlabs.com/browse/SERVER-528
service puppet stop
service puppetserver stop
rm -rf /etc/puppetlabs/puppet/ssl/private_keys/*
rm -rf /etc/puppetlabs/puppet/ssl/certs/*

echo 'autosign = true' >> /etc/puppetlabs/puppet/puppet.conf
service puppetserver start

# Puppet agent looks for the server called "puppet" by default.
# In this case, we want that to be us (the loopback address).
echo '127.0.0.1 localhost puppet' > /etc/hosts

# Install puppet-logstash dependencies.
for mod in puppetlabs-apt puppetlabs-stdlib electrical-file_concat; do
    puppet module install --target-dir=/etc/puppetlabs/code/environments/production/modules $mod
done
