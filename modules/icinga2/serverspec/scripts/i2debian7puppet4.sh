if ! $(dpkg-query --show puppetlabs-release-pc1 1>/dev/null); then
  wget https://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb 2>/dev/null
  dpkg -i puppetlabs-release-pc1-wheezy.deb
  rm -f puppetlabs-release-pc1-wheezy.deb
fi

apt-get update 2>&1

dpkg-query --show puppet-agent 1>/dev/null || apt-get -y --force-yes install puppet-agent
