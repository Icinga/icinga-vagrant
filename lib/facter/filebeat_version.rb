require 'facter'
Facter.add('filebeat_version') do
  confine :kernel => %w(Linux Windows)
  setcode do
    if File.executable?('/usr/bin/filebeat')
      filebeat_version = Facter::Util::Resolution.exec('/usr/bin/filebeat --version')
    elsif File.executable?('/usr/share/filebeat/bin/filebeat')
      filebeat_version = Facter::Util::Resolution.exec('/usr/share/filebeat/bin/filebeat --version')
    elsif File.executable?('C:/Program Files/Filebeat/filebeat.exe --version')
      filebeat_version = Facter::Util::Resolution.exec('C:/Program Files/Filebeat/filebeat.exe --version')
    end
    %r{^filebeat version ([^\s]+)?}.match(filebeat_version)[1] unless filebeat_version.nil?
  end
end
