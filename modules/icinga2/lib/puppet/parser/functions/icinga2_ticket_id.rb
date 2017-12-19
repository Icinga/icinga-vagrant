require File.join(File.dirname(__FILE__), '../../..', 'puppet_x/icinga2/pbkdf2.rb')

module Puppet::Parser::Functions
  newfunction(:icinga2_ticket_id, :type => :rvalue) do |args|
    raise Puppet::ParseError, 'Must provide exactly two arguments to icinga2_ticket_id' if args.length != 2

    if !args[0] or args[0] == ''
      raise Puppet::ParseError, 'first argument (cn) can not be empty for icinga2_ticket_id'
    end
    if !args[1] or args[1] == ''
      raise Puppet::ParseError, 'second argument (salt) can not be empty for icinga2_ticket_id'
    end

    PBKDF2.new(
      :password => args[0],
      :salt => args[1],
      :iterations => 50000,
      :hash_function => OpenSSL::Digest.new("sha1")
    ).hex_string
  end
end
