# snmpv3_usm_hash.rb --- Calculate SNMPv3 USM hash for a passphrase
Puppet::Functions.create_function(:'snmp::snmpv3_usm_hash') do
  # @api private
  # Calculate SNMPv3 USM hash for a passphrase
  #
  # The algorithm is implemented according to RFC-3414 sections A.2.1/A.2.2.
  #
  # @param authtype The authentication type to calculate. This must either be
  # 'SHA' or 'MD5'.
  #
  # @param engine The SNMP engine used. The value is used as salt and must
  # match the value used by the SNMP daemon.
  #
  # @param passphrase The passphrase for which the hash is calculated.
  #
  # @param bits The number of bits the result should be truncated to if it is
  # longer. If the function is used to calculate the key for the privacy
  # protocol it must be truncated to exactly 128 bits.
  #
  # @return [String] The calculated hash.
  #
  dispatch :snmpv3_usm_hash do
    required_param "Enum['SHA','MD5']", :authtype
    required_param 'String', :engine
    required_param 'String[8]', :passphrase
    optional_param 'Integer', :bits
    return_type 'String'
  end

  def snmpv3_usm_hash(authtype, engine, passphrase, bits = nil)
    require 'digest'

    # Create an instance of the selected digest
    digest_instance = case authtype
                      when 'SHA'
                        Digest::SHA1.new
                      when 'MD5'
                        Digest::MD5.new
                      end

    # The hash will be calculated over exactly 1 megabyte filled using the
    # passphrase. We do not actually create a buffer that large but instead
    # use the incremental update functionality of the digest instance.
    remaining_chars = 1_048_576 # 1024 * 1024

    while remaining_chars > 0
      if remaining_chars < passphrase.length
        # Only the first couple of characters are needed to fill the megabyte
        passphrase = passphrase.slice(0, remaining_chars)
      end

      # Update digest with the next part
      digest_instance << passphrase

      # Reduce remaining work by what we have done just now
      remaining_chars -= passphrase.length
    end

    # Use engine as salt (remove leading '0x' if found)
    salt = [engine.sub(%r{^0x}, '')].pack('H*')

    # Calculate hash
    hash = digest_instance.digest

    hexdigest = digest_instance.hexdigest(hash + salt + hash)

    # truncate string if requested (each hex char represents 4 bits)
    hexdigest = hexdigest[0, bits / 4] unless bits.nil?

    # Return digest as hexstring
    '0x' << hexdigest
  end
end
