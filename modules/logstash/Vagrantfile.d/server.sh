# Install and configure puppetserver.
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apt-transport-https
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
for mod in puppetlabs-apt puppetlabs-stdlib; do
    puppet module install --target-dir=/etc/puppetlabs/code/environments/production/modules $mod
done

# Install Java 8 for Logstash.
apt-get install openjdk-8-jre-headless
java -version

# Place a manifest to test the Logstash module.
cat <<EOF > /etc/puppetlabs/code/environments/production/manifests/site.pp
class { 'logstash':
  manage_repo  => true,
  repo_version => '5.x',
  version      => '1:5.0.1-1',
}

logstash::configfile { 'basic_config':
  content => 'input { tcp { port => 2000 } } output { null {} }'
}
EOF
