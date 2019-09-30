require 'net/http'
require 'json'
require 'yaml'

# Helper module to encapsulate custom fact injection
# rubocop:disable Metrics/ModuleLength
module EsFacts
  # Add a fact to the catalog of host facts
  def self.add_fact(prefix, key, value)
    key = "#{prefix}_#{key}".to_sym
    ::Facter.add(key) do
      setcode { value }
    end
  end

  def self.ssl?(config)
    tls_keys = [
      'xpack.security.http.ssl.enabled',
      'shield.http.ssl',
      'searchguard.ssl.http.enabled'
    ]

    tls_keys.any? { |key| (config.key? key) && (config[key] == true) }
  end

  # Helper to determine the instance http.port number
  def self.get_httpport(config)
    enabled = 'http.enabled'
    httpport = 'http.port'

    if !config[enabled].nil? && config[enabled] == 'false'
      false
    elsif !config[httpport].nil?
      { config[httpport] => ssl?(config) }
    else
      { '9200' => ssl?(config) }
    end
  end

  # Entrypoint for custom fact populator
  #
  # This is a super old function but works; disable a bunch of checks.
  # rubocop:disable Lint/HandleExceptions
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.run
    dir_prefix = '/etc/elasticsearch'
    # httpports is a hash of port_number => ssl?
    httpports = {}
    transportports = []
    http_bound_addresses = []
    transport_bound_addresses = []
    transport_publish_addresses = []
    nodes = {}

    # only when the directory exists we need to process the stuff
    return unless File.directory?(dir_prefix)

    Dir.foreach(dir_prefix) do |dir|
      next if dir == '.'

      if File.readable?("#{dir_prefix}/#{dir}/elasticsearch.yml")
        config_data = YAML.load_file("#{dir_prefix}/#{dir}/elasticsearch.yml")
        httpport = get_httpport(config_data)
        httpports.merge! httpport if httpport
      end
    end

    begin
      if httpports.keys.count > 0

        add_fact('elasticsearch', 'ports', httpports.keys.join(','))

        httpports.each_pair do |httpport, ssl|
          next if ssl

          key_prefix = "elasticsearch_#{httpport}"

          uri = URI("http://localhost:#{httpport}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.read_timeout = 10
          http.open_timeout = 2
          response = http.get('/')
          json_data = JSON.parse(response.body)
          next if json_data['status'] && json_data['status'] != 200

          add_fact(key_prefix, 'name', json_data['name'])
          add_fact(key_prefix, 'version', json_data['version']['number'])

          uri2 = URI("http://localhost:#{httpport}/_nodes/#{json_data['name']}")
          http2 = Net::HTTP.new(uri2.host, uri2.port)
          http2.read_timeout = 10
          http2.open_timeout = 2
          response2 = http2.get(uri2.path)
          json_data_node = JSON.parse(response2.body)

          add_fact(key_prefix, 'cluster_name', json_data_node['cluster_name'])
          node_data = json_data_node['nodes'].first

          add_fact(key_prefix, 'node_id', node_data[0])

          nodes_data = json_data_node['nodes'][node_data[0]]

          process = nodes_data['process']
          add_fact(key_prefix, 'mlockall', process['mlockall'])

          plugins = nodes_data['plugins']

          plugin_names = []
          plugins.each do |plugin|
            plugin_names << plugin['name']

            plugin.each do |key, value|
              prefix = "#{key_prefix}_plugin_#{plugin['name']}"
              add_fact(prefix, key, value) unless key == 'name'
            end
          end
          add_fact(key_prefix, 'plugins', plugin_names.join(','))

          nodes_data['http']['bound_address'].each { |i| http_bound_addresses << i }
          nodes_data['transport']['bound_address'].each { |i| transport_bound_addresses << i }
          transport_publish_addresses << nodes_data['transport']['publish_address'] unless nodes_data['transport']['publish_address'].nil?
          transportports << nodes_data['settings']['transport']['tcp']['port'] unless nodes_data['settings']['transport']['tcp'].nil? or nodes_data['settings']['transport']['tcp']['port'].nil?

          node = { 'http_ports' => httpports.keys,
                   'transport_ports' => transportports,
                   'http_bound_addresses' => http_bound_addresses,
                   'transport_bound_addresses' => transport_bound_addresses,
                   'transport_publish_addresses' => transport_publish_addresses,
                   json_data['name'] => { 'settings' => nodes_data['settings'], 'http' => nodes_data['http'], 'transport' => nodes_data['transport'] } }
          nodes.merge! node
        end
      end
    rescue
    end
    Facter.add(:elasticsearch) do
      setcode do
        nodes
      end
      nodes unless nodes.empty?
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end

EsFacts.run
