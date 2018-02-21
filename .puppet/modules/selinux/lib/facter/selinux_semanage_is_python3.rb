Facter.add(:selinux_semanage_is_python3) do
  confine osfamily: 'RedHat'
  setcode do
    Facter::Core::Execution.execute('rpm -q libsemanage-python3') !~ %r{not installed}
  end
end
