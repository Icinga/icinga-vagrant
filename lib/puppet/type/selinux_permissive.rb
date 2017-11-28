Puppet::Type.newtype(:selinux_permissive) do
  @doc = 'Manage SELinux permissive types.'

  ensurable

  newparam(:seltype) do
    desc 'The SELinux type that should be permissive'
    isnamevar
  end

  newparam(:local) do
    desc 'A read-only attribue indicating whether the type is locally customized'
    newvalues(true, false)
  end
end
