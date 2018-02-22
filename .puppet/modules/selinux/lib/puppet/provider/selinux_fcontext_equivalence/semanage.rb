Puppet::Type.type(:selinux_fcontext_equivalence).provide(:semanage) do
  desc 'Support managing SELinux custom fcontext definitions via semanage'

  defaultfor kernel: 'Linux'

  commands semanage: 'semanage'
  confine selinux: true

  mk_resource_methods

  def self.parse_fcontext_subs_lines(lines)
    ret = []
    lines.each do |line|
      next if line.strip.empty?
      next if line =~ %r{^#}
      source, target = line.split(%r{\s+})
      ret.push(new(ensure: :present,
                   name: source,
                   target: target))
    end
    ret
  end

  def self.instances
    # Allow this to fail with an exception if it does not exist
    path = Selinux.selinux_file_context_subs_path
    if File.exist? path
      lines = File.readlines(path)
      parse_fcontext_subs_lines(lines)
    else
      # No file, no equivalences:
      []
    end
  end

  def self.prefetch(resources)
    # is there a better way to do this? map port/protocol pairs to the provider regardless of the title
    # and make sure all system resources have ensure => :present so that we don't try to remove them
    instances.each do |provider|
      resource = resources[provider.name]
      resource.provider = provider if resource
    end
  end

  def create
    semanage('fcontext', '-a', '-e', @resource[:target], @resource[:path])
  end

  def destroy
    semanage('fcontext', '-d', '-e', @property_hash[:target], @property_hash[:name])
  end

  def target=(val)
    # apparently --modify does not work... Must delete and create anew
    # -N for noreload, so it's "atomic"
    semanage('fcontext', '-N', '-d', '-e', @property_hash[:target], @property_hash[:name])
    semanage('fcontext', '-a', '-e', val, @property_hash[:name])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
