require File.join(File.dirname(__FILE__), '../../..', 'puppet_x/icinga2/utils.rb')

module Puppet::Parser::Functions
  newfunction(:icinga2_attributes, :type => :rvalue) do |args|
    raise Puppet::ParseError, 'Must provide at least one argument.' if args.length > 4

    if args[1]
      indent = args[1]
    else
      indent = 0
    end

    if args[2]
      globals = args[2].concat(lookupvar('::icinga2::params::globals'))
    else
      globals = lookupvar('::icinga2::params::globals')
    end

    if args[3]
      constants = args[3].merge(lookupvar('::icinga2::_constants'))
    else
      constants = lookupvar('::icinga2::_constants')
    end

    Puppet::Icinga2::Utils.attributes(args[0], globals, constants, indent)
  end
end
