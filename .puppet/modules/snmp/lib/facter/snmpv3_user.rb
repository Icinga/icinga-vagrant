# snmpv3_user.rb --- Get SNMP usmUser data from configuration
Facter.add(:snmpv3_user) do
  confine :os do |os|
    %w[Debian RedHat Suse].include? os['family']
  end

  setcode do
    fact = {}

    config = case Facter.value(:os)['family']
             when 'Debian'  then '/var/lib/snmp/snmpd.conf'
             when 'RedHat'  then '/var/lib/net-snmp/snmpd.conf'
             when 'Suse'    then '/var/lib/net-snmp/snmpd.conf'
             end

    begin
      File.readlines(config).each do |line|
        next unless %r{^usmUser} =~ line

        # split into items using whitespace delimiter
        items = line.split

        # need at least 11 items
        next unless items.length >= 11

        # extract user field and remove quotes
        user = items[4].gsub(%r{\A['"]+|['"]+\Z}, '')

        # convert hex string to ascii if necessary
        # handle '0x' prefix and trailing NULL
        user = [user[2..-1]].pack('H*').delete("\000") if %r{^0x} =~ user

        # map OID to string for auth protocol
        authproto = case items[7]
                    when '.1.3.6.1.6.3.10.1.1.1' then 'usmNoAuthProtocol'
                    when '.1.3.6.1.6.3.10.1.1.2' then 'usmHMACMD5AuthProtocol'
                    when '.1.3.6.1.6.3.10.1.1.3' then 'usmHMACSHA1AuthProtocol'
                    else 'usmUnknownAuthProtocol'
                    end

        authhash = items[8].gsub(%r{\A['"]+|['"]+\Z}, '')
        authhash = '' if authhash == '0x'

        # map OID to string for priv protocol
        privproto = case items[9]
                    when '.1.3.6.1.6.3.10.1.2.1' then 'usmNoPrivProtocol'
                    when '.1.3.6.1.6.3.10.1.2.2' then 'usmDESPrivProtocol'
                    when '.1.3.6.1.6.3.10.1.2.4' then 'usmAESPrivProtocol'
                    else 'usmUnknownPrivProtocol'
                    end

        privhash = items[10].gsub(%r{\A['"]+|['"]+\Z}, '')
        privhash = '' if privhash == '0x'

        fact[user] = {
          engine:    items[3],
          authproto: authproto,
          authhash:  authhash,
          privproto: privproto,
          privhash:  privhash
        }
      end
    rescue
      fact = {}
    end

    fact
  end
end
