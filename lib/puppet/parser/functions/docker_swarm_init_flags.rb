# frozen_string_literal: true

require 'shellwords'
#
# docker_swarm_init_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:docker_swarm_init_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['init'].to_s != 'false'
      flags << 'init'
    end

    if opts['advertise_addr'] && opts['advertise_addr'].to_s != 'undef'
      flags << "--advertise-addr '#{opts['advertise_addr']}'"
    end

    if opts['autolock'].to_s != 'false'
      flags << '--autolock'
    end

    if opts['cert_expiry'] && opts['cert_expiry'].to_s != 'undef'
      flags << "--cert-expiry '#{opts['cert_expiry']}'"
    end

    if opts['default_addr_pool'].is_a? Array
      opts['default_addr_pool'].each do |default_addr_pool|
        flags << "--default-addr-pool #{default_addr_pool}"
      end
    end

    if opts['default_addr_pool_mask_length'] && opts['default_addr_pool_mask_length'].to_s != 'undef'
      flags << "--default-addr-pool-mask-length '#{opts['default_addr_pool_mask_length']}'"
    end

    if opts['dispatcher_heartbeat'] && opts['dispatcher_heartbeat'].to_s != 'undef'
      flags << "--dispatcher-heartbeat '#{opts['dispatcher_heartbeat']}'"
    end

    if opts['external_ca'] && opts['external_ca'].to_s != 'undef'
      flags << "--external-ca '#{opts['external_ca']}'"
    end

    if opts['force_new_cluster'].to_s != 'false'
      flags << '--force-new-cluster'
    end

    if opts['listen_addr'] && opts['listen_addr'].to_s != 'undef'
      flags << "--listen-addr '#{opts['listen_addr']}'"
    end

    if opts['max_snapshots'] && opts['max_snapshots'].to_s != 'undef'
      flags << "--max-snapshots '#{opts['max_snapshots']}'"
    end

    if opts['snapshot_interval'] && opts['snapshot_interval'].to_s != 'undef'
      flags << "--snapshot-interval '#{opts['snapshot_interval']}'"
    end

    flags.flatten.join(' ')
  end
end
