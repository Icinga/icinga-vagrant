Puppet::Type.newtype(:selinux_port) do
  @doc = 'Manage SELinux port definitions. You should use selinux::port instead of this directly.'

  ensurable

  newparam(:title, namevar: true) do
    desc 'Should be of the form "protocol_lowport-highport" or the type may misbehave'
  end

  newproperty(:low_port) do
    desc 'The low end of the port range to manage'
    isrequired

    validate do |val|
      val = Integer(val)
      if val < 1 || val > 65_535
        raise ArgumentError, "Illegal port value '#{val}'"
      end
    end
  end

  newproperty(:high_port) do
    desc 'The high end of the port range to manage'
    isrequired

    validate do |val|
      val = Integer(val)
      if val < 1 || val > 65_535
        raise ArgumentError, "Illegal port value '#{val}'"
      end
    end
  end

  newproperty(:protocol) do
    desc 'The protocol of the SELinux port definition'
    newvalues(:tcp, :udp)
    isrequired
  end

  newproperty(:seltype) do
    desc 'The SELinux type of the SELinux port definition'
  end

  newproperty(:source) do
    desc 'Source of the port configuration - either policy or local'
    newvalues(:policy, :local)

    validate do |_value|
      raise ArgumentError, ':source is a read-only property'
    end
  end
end
