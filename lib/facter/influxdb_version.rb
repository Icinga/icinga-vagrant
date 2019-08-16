#

Facter.add(:influxdb_version) do
  setcode do
    if Facter::Util::Resolution.which('influx')

      # InfluxDB shell version: 1.1.1
      version_stdout = Facter::Util::Resolution.exec('influx --version')
      match = version_stdout.match(%r{[0-9]+\.[0-9]+\.[0-9]+})

      match ? match[0] : nil
    end
  end
end
