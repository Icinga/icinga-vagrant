Facter.add(:selinux_semanage_is_python3) do
  confine osfamily: 'RedHat'
  setcode do
    Facter::Core::Execution.execute('rpm -q python3-libsemanage') !~ %r{not installed}
  end
end
