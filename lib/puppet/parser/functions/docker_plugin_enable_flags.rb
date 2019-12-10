# frozen_string_literal: true

require 'shellwords'
#
# docker_plugin_remove_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker plugin remove flags
  newfunction(:docker_plugin_enable_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << '--force' if opts['force_remove'] == true
    if opts['plugin_alias'] && opts['plugin_alias'].to_s != 'undef'
      flags << "'#{opts['plugin_alias']}'"
    elsif opts['plugin_name'] && opts['plugin_name'].to_s != 'undef'
      flags << "'#{opts['plugin_name']}'"
    end
    flags.flatten.join(' ')
  end
end
