rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppet

rpm -aq |grep puppetlabs-release 1>/dev/null || zypper install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-sles-12.noarch.rpm

rpm -q puppet-agent || zypper install -y puppet-agent

test -x /bin/puppet || ln -s /opt/puppetlabs/bin/puppet /bin/puppet
