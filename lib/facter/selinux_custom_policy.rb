# selinux_custom_policy.rb

Facter.add(:selinux_custom_policy) do
  confine :kernel => 'Linux', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :selinux => true

  selinux_custom_policy = Facter::Core::Execution.exec('sestatus | grep "Loaded policy name" | awk \'{print $4}\'')

  setcode do
    selinux_custom_policy
  end
end
