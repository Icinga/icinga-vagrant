#!/bin/bash

set -e

pkgtype="$1"

setup_apt()
{
	local codename=$(lsb_release -cs)
	local repo_package="puppetlabs-release-${codename}.deb"

	apt-get -y update
	apt-get -y install wget

	wget -nv http://apt.puppetlabs.com/$repo_package

	dpkg -i $repo_package
	apt-get -y update
	apt-get -y install puppet
}

setup_yum()
{
	# Needed for /usr/bin/lsb_release script.
	yum install -y redhat-lsb-core

	local release=$(lsb_release -rs)
	local repo_package="puppetlabs-release-el-${release%.*}.noarch.rpm"

	rpm -Uh http://yum.puppetlabs.com/$repo_package

	yum install -y puppet
}


case "$pkgtype" in
apt)
	setup_apt
	;;
yum)
	setup_yum
	;;
esac

puppet module install -i /etc/puppet/modules puppetlabs-stdlib
puppet module install -i /etc/puppet/modules puppetlabs-apt
puppet module install -i /etc/puppet/modules elasticsearch-elasticsearch
puppet module install -i /etc/puppet/modules puppetlabs-mongodb

ln -s /vagrant /etc/puppet/modules/graylog2
