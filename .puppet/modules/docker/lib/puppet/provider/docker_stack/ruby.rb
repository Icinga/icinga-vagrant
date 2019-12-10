# frozen_string_literal: true

require 'deep_merge'

Puppet::Type.type(:docker_stack).provide(:ruby) do
  desc 'Support for Puppet running Docker Stacks'

  mk_resource_methods
  commands docker: 'docker'

  def exists?
    Puppet.info("Checking for stack #{name}")
    stack_services = {}
    stack_containers = []
    resource[:compose_files].each do |file|
      compose_file = YAML.safe_load(File.read(file), [], [], true)
      # rubocop:disable Style/StringLiterals
      containers = docker([
                            'ps',
                            '--format',
                            "{{.Label \"com.docker.swarm.service.name\"}}-{{.Image}}",
                            '--filter',
                            "label=com.docker.stack.namespace=#{name}",
                          ]).split("\n").each do |c|
                            c.slice!("#{name}_")
                          end
      stack_containers.push(*containers)
      stack_containers.uniq!
      # rubocop:enable Style/StringLiterals
      case compose_file['version']
      when %r{^3(\.[0-7])?$}
        stack_services.merge!(compose_file['services'])
      else
        raise(Puppet::Error, "Unsupported docker compose file syntax version \"#{compose_file['version']}\"!")
      end
    end

    if stack_services.count != stack_containers.count
      return false
    end
    counts = Hash[*stack_services.each.map { |key, array|
                    image = (array['image']) ? array['image'] : get_image(key, stack_services)
                    image = "#{image}:latest" unless image.include?(':')
                    Puppet.info("Checking for compose service #{key} #{image}")
                    ["#{key}-#{image}", stack_containers.count("#{key}-#{image}")]
                  }.flatten]
    # No containers found for the project
    if counts.empty? ||
       # Containers described in the compose file are not running
       counts.any? { |_k, v| v.zero? }
      false
    else
      true
    end
  end

  def get_image(service_name, stack_services)
    image = stack_services[service_name]['image']
    unless image
      if stack_services[service_name]['extends']
        image = get_image(stack_services[service_name]['extends'], stack_services)
      elsif stack_services[service_name]['build']
        image = "#{name}_#{service_name}"
      end
    end
    image
  end

  def create
    Puppet.info("Running stack #{name}")
    args = ['stack', 'deploy', compose_files, name].insert(1, bundle_file).insert(4, resource[:up_args]).compact
    docker(args)
  end

  def destroy
    Puppet.info("Removing docker stack #{name}")
    rm_args = ['stack', 'rm', name]
    docker(rm_args)
  end

  def bundle_file
    return resource[:bundle_file].map { |x| ['-c', x] }.flatten unless resource[:bundle_file].nil?
  end

  def compose_files
    resource[:compose_files].map { |x| ['-c', x] }.flatten
  end

  private
end
