require 'json'

# rubocop:disable Metrics/AbcSize
class Puppet::Provider::ElasticKibana < Puppet::Provider
  class << self
    attr_accessor :home_path
    attr_accessor :install_args
    attr_accessor :plugin_directory
    attr_accessor :remove_args
  end

  def self.present_plugins
    Dir[File.join(home_path, plugin_directory, '*')].select do |directory|
      not File.basename(directory).start_with? '.' \
        and File.exist? File.join(directory, 'package.json')
    end.map do |plugin|
      j = JSON.parse(File.read(File.join(plugin, 'package.json')))
      {
        :name => File.basename(plugin),
        :ensure => :present,
        :provider => name,
        :version => j['version']
      }
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      # Simply remove the plugin if it should be gone
      run_plugin self.class.remove_args + [resource[:name]]
    else
      unless @property_flush[:version].nil?
        run_plugin self.class.remove_args + [resource[:name]]
      end
      run_plugin self.class.install_args + [plugin_url]
    end

    set_property_hash
  end

  def run_plugin(args)
    debug(
      execute([command(:plugin)] + args, :uid => 'kibana', :gid => 'kibana')
    )
  end

  def plugin_url
    if not resource[:url].nil?
      resource[:url]
    elsif not resource[:organization].nil?
      [resource[:organization], resource[:name], resource[:version]].join('/')
    else
      resource[:name]
    end
  end

  # The rest is normal provider boilerplate.

  def version=(new_version)
    @property_flush[:version] = new_version
  end

  def version
    @property_hash[:version]
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def set_property_hash
    @property_hash = self.class.present_plugins.detect do |p|
      p[:name] == resource[:name]
    end
  end

  def self.instances
    present_plugins.map do |plugin|
      new plugin
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end
end
