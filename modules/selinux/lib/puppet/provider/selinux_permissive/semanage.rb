Puppet::Type.type(:selinux_permissive).provide(:semanage) do
  desc 'Support managing SELinux permissive types definitions via semanage'

  defaultfor kernel: 'Linux'
  # SELinux must be enabled. Is there a way to get a better error message?
  confine selinux: true

  commands semanage: 'semanage'

  mk_resource_methods

  def self.instances
    lines = semanage('permissive', '--list').split("\n")
    res = {}
    # we need this logic because semanage on older systems doesn't support
    # --locallist and returns things in different order.
    local = true
    lines.each do |line|
      if line =~ %r{Builtin}
        local = false
        next
      end
      if line =~ %r{Custom}
        local = true
        next
      end
      next if line.strip.empty?
      name = line.strip
      # do not use built-in provider if we find a customized type
      next if res[name] && !local

      # If I remove name: from here purging will not work.
      res[name] = new(name: name, seltype: name, ensure: :present, local: local)
    end
    res.values
  end

  def self.prefetch(resources)
    debug(resources.keys)
    instances.each do |provider|
      resource = resources[provider.seltype]
      # consider built-in resources absent for purposes of purging
      next unless resource
      resource.provider = provider
      if resource.purging? && !provider.local
        debug("Can't purge built-in resource #{resource[:seltype]}")
        resource[:ensure] = :present
      end
    end
  end

  def create
    semanage('permissive', '-a', @resource[:seltype])
  end

  def destroy
    semanage('permissive', '-d', @resource[:seltype])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
