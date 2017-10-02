#!/usr/bin/env ruby
#
# Script for icinga2-vagrant to prepare the Graylog2 server with some inputs
# and streams.

require 'json'
require 'uri'
require 'net/http'
require 'facter'

$stdout.sync = true

class HTTPClient < Struct.new(:url)
  class Response < Struct.new(:response)
    def body
      response.body
    end

    def data
      JSON.parse(response.body)
    end

    def success?
      response.is_a?(Net::HTTPSuccess)
    end
  end

  def uri
    @uri ||= URI(url)
  end

  def request(req)
    Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
  end

  def host_alive?
    !!Net::HTTP.get(URI.join(uri, 'system'))
  rescue
    false
  end

  def post(path, body = nil)
    req = Net::HTTP::Post.new(path)
    req.basic_auth(uri.user, uri.password)
    req['Content-Type'] = 'application/json'
    req.body = JSON.dump(body) if body

    Response.new(request(req))
  end

  def get(path)
    req = Net::HTTP::Get.new(path)
    req.basic_auth(uri.user, uri.password)

    Response.new(request(req))
  end
end

class Graylog2Server < Struct.new(:client)
  def get_node_id
    res = client.get('/api/system')

    res.data['node_id']
  end

  def has_input?(type)
    response = client.get('/api/system/inputs')

    input = response.data['inputs'].find do |i|
      i['type'][type]
    end

    !input.nil?
  end

  def has_stream_alert?(title)
    !!get_stream_alert(title)
  end

  def add_input(data)
    client.post('/api/system/inputs', data)
  end

  def add_stream_alert(title, data)
    stream_id = get_stream(title)['id']

    client.post("/api/streams/#{stream_id}/alerts/conditions", data)
  end

  def get_stream(title)
    response = client.get('/api/streams')

    response.data['streams'].find {|i| i['title'][title] }
  end

  def get_stream_alert(title)
    response = client.get('/api/alerts/conditions')

    response.data['conditions'].find {|i| i['title'][title] }
  end

  def wait_until_alive(interval, additional_interval, limit = 600)
    waited = 0

    until client.host_alive?
      yield(waited) if block_given?
      sleep(interval)
      waited += interval

      if waited >= limit
        raise "Waited for #{limit}s - something seems to be wrong with the server."
      end
    end

    # Sleeping some extra seconds to wait until all inputs have been started...
    sleep(additional_interval) if waited > 0
  end
end


## MAIN

#ipaddress = Facter.fact(:ipaddress).value # TODO: Use Hiera
ipaddress = '192.168.33.6'
client = HTTPClient.new("http://admin:admin@#{ipaddress}:9000/api/")
server = Graylog2Server.new(client)

# Wait until the Graylog2 server is reachable.
server.wait_until_alive(2, 6) do |seconds|
  puts "Waiting for server to startup. (elapsed: #{seconds}s)"
end

node_id = server.get_node_id

if server.has_input?('org.graylog2.inputs.gelf.tcp.GELFTCPInput')
  puts '==> GELFTCPInput exists'
else
  server.add_input({
    global: 'false',
    title: 'Gelf TCP',
    configuration: {
      port: 12201,
      bind_address: '0.0.0.0'
    },
    type: 'org.graylog2.inputs.gelf.tcp.GELFTCPInput',
    node: node_id
  })

  puts '==> Added GELFTCPInput'
end

if server.has_input?('org.graylog2.inputs.gelf.udp.GELFUDPInput')
  puts '==> GELFUDPInput exists'
else
  server.add_input({
    global: 'false',
    title: 'Gelf UDP',
    configuration: {
      port: 12201,
      bind_address: '0.0.0.0'
    },
    type: 'org.graylog2.inputs.gelf.udp.GELFUDPInput',
    node: node_id
  })

  puts '==> Added GELFUDPInput'
end

if server.has_stream_alert?('Message count alert')
  puts '==> Stream alert exists'
else
  server.add_stream_alert('All messages', {
    type: 'message_count',
    title: 'Message count alert',
    parameters: {
      grace: 10,
      time: 5,
      backlog: 0,
      threshold_type: 'more',
      threshold: 3
    }
  })

  puts '==> Added stream alert for "All messages"'
end
