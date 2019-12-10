# frozen_string_literal: true

Puppet::Type.newtype(:docker_stack) do
  @doc = 'A type representing a Docker Stack'

  ensurable

  newparam(:bundle_file) do
    desc 'Path to a Distributed Application Bundle file.'
    validate do |value|
      raise _('bundle files should be a string') unless value.is_a? String
    end
  end

  newparam(:compose_files, array_matching: :all) do
    desc 'An array of Docker Compose Files paths.'
    validate do |value|
      raise _('compose files should be an array') unless value.is_a? Array
    end
  end

  newparam(:up_args) do
    desc 'Arguments to be passed directly to docker stack deploy.'
    validate do |value|
      raise _('up_args should be a String') unless value.is_a? String
    end
  end

  newparam(:name) do
    isnamevar
    desc 'The name of the stack'
  end
end
