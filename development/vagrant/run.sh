#!/bin/bash

exec sudo puppet apply --show_diff \
	--modulepath /etc/puppet/modules:/vagrant/modules \
	/vagrant/development/vagrant/site.pp
