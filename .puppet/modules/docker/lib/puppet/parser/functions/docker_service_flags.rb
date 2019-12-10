# frozen_string_literal: true

require 'shellwords'
#
# docker_service_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:docker_service_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['service_name'] && opts['service_name'].to_s != 'undef'
      flags << "'#{opts['service_name']}'"
    end

    if opts['detach'].to_s != 'false'
      flags << '--detach'
    end

    if opts['env'].is_a? Array
      opts['env'].each do |env|
        flags << "--env #{env}"
      end
    end

    if opts['label'].is_a? Array
      opts['label'].each do |label|
        flags << "--label #{label}"
      end
    end

    if opts['mounts'].is_a? Array
      opts['mounts'].each do |mount|
        flags << "--mount #{mount}"
      end
    end

    if opts['networks'].is_a? Array
      opts['networks'].each do |network|
        flags << "--network #{network}"
      end
    end

    if opts['publish'].is_a? Array
      opts['publish'].each do |port|
        flags << "--publish #{port}"
      end
    elsif opts['publish'] && opts['publish'].to_s != 'undef'
      flags << "--publish '#{opts['publish']}'"
    end

    if opts['replicas'] && opts['replicas'].to_s != 'undef'
      flags << "--replicas '#{opts['replicas']}'"
    end

    if opts['tty'].to_s != 'false'
      flags << '--tty'
    end

    if opts['user'] && opts['user'].to_s != 'undef'
      flags << "--user '#{opts['publish']}'"
    end

    if opts['workdir'] && opts['workdir'].to_s != 'undef'
      flags << "--workdir '#{opts['workdir']}'"
    end

    if opts['extra_params'].is_a? Array
      opts['extra_params'].each do |param|
        flags << param
      end
    end

    if opts['host_socket'] && opts['host_socket'].to_s != 'undef'
      flags << "-H '#{opts['host_socket']}'"
    end

    if opts['registry_mirror'] && opts['registry_mirror'].to_s != 'undef'
      flags << "--registry-mirror='#{opts['registry_mirror']}'"
    end

    if opts['image'] && opts['image'].to_s != 'undef'
      flags << "'#{opts['image']}'"
    end

    if opts['command'].is_a? Array
      flags << opts['command'].join(' ')
    elsif opts['command'] && opts['command'].to_s != 'undef'
      flags << opts['command'].to_s
    end

    flags.flatten.join(' ')
  end
end
