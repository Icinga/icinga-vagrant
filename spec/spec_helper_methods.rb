def os_specific_facts(facts)
  case facts[:os]['family']
  when 'Archlinux'
    { service_provider: 'systemd' }
  when 'Debian'
    case facts[:os]['release']['major']
    when '7'
      { service_provider: 'sysv' }
    when '8'
      { service_provider: 'systemd' }
    when '9'
      { service_provider: 'systemd' }
    when '14.04'
      { service_provider: 'upstart' }
    when '16.04'
      { service_provider: 'systemd' }
    when '18.04'
      { service_provider: 'systemd' }
    end
  when 'RedHat'
    case facts[:os]['release']['major']
    when '6'
      { service_provider: 'sysv' }
    when '7'
      { service_provider: 'systemd' }
    when '8'
      { service_provider: 'systemd' }
    end
  end
end
