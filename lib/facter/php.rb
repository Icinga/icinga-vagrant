# Simple facts to get PHP version, *after* PHP is installed.
# Mostly useful for reporting and inventory, not so much from Puppet manifests.

php_version = Facter::Util::Resolution.exec('/usr/bin/env php -r "echo PHP_VERSION;" 2>/dev/null')

# PHP uses semantic versioning x.y.z
if php_version =~ /^\d+\.\d+\.\d+$/
  Facter.add(:php_version) { setcode { php_version } }
  Facter.add(:php_majversion) { setcode { php_version[/^\d+/] } }
  Facter.add(:php_minversion) { setcode { php_version[/^\d+\.\d+/] } }
end

