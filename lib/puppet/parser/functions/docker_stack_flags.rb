# frozen_string_literal: true

require 'shellwords'
#
# docker_stack_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker stack flags
  newfunction(:docker_stack_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['bundle_file'] && opts['bundle_file'].to_s != 'undef'
      flags << "--bundle-file '#{opts['bundle_file']}'"
    end

    if opts['compose_files'] && opts['compose_files'].to_s != 'undef'
      opts['compose_files'].each do |file|
        flags << "--compose-file '#{file}'"
      end
    end

    if opts['resolve_image'] && opts['resolve_image'].to_s != 'undef'
      flags << "--resolve-image '#{opts['resolve_image']}'"
    end

    if opts['prune'] && opts['prune'].to_s != 'undef'
      flags << '--prune'
    end

    if opts['with_registry_auth'] && opts['with_registry_auth'].to_s != 'undef'
      flags << '--with-registry-auth'
    end

    flags.flatten.join(' ')
  end
end
