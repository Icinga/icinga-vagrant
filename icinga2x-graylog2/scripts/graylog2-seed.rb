#!/usr/bin/env ruby
#
# Script for icinga2-vagrant to prepare the Graylog2 server with some inputs
# and streams.

require 'json'
require 'uri'
require 'net/http'

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
    !!Net::HTTP.get(uri)
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
  def has_input?(type)
    response = client.get('/system/inputs')

    input = response.data['inputs'].find do |i|
      i['message_input']['type'][type]
    end

    !input.nil?
  end

  def has_stream?(title)
    !!get_stream(title)
  end

  def add_input(data)
    client.post('/system/inputs', data)
  end

  def add_stream(data)
    response = client.post('/streams', data)
    stream_id = response.data['stream_id']

    client.post("/streams/#{stream_id}/resume")
  end

  def add_stream_alert(title, data)
    stream_id = get_stream(title)['id']

    client.post("/streams/#{stream_id}/alerts/conditions", data)
  end

  def get_stream(title)
    response = client.get('/streams')

    response.data['streams'].find {|i| i['title'][title] }
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

client = HTTPClient.new('http://admin:admin@127.0.0.1:12900/')
server = Graylog2Server.new(client)

# Wait until the Graylog2 server is reachable.
server.wait_until_alive(2, 6) do |seconds|
  puts "Waiting for server to startup. (elapsed: #{seconds}s)"
end

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
    creator_user_id: 'admin',
    type: 'org.graylog2.inputs.gelf.tcp.GELFTCPInput'
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
    creator_user_id: 'admin',
    type: 'org.graylog2.inputs.gelf.udp.GELFUDPInput'
  })

  puts '==> Added GELFUDPInput'
end

if server.has_stream?('Catch all')
  puts '==> Stream "Catch all" exists'
else
  server.add_stream({
    title: 'Catch all',
    description: 'All messages',
    creator_user_id: 'admin',
    rules: [
      {
        field: 'message',
        value: '.*',
        type: 2,
        inverted: false
      }
    ]
  })

  server.add_stream_alert('Catch all', {
    type: 'message_count',
    creator_user_id: 'admin',
    parameters: {
      grace: 10,
      time: 5,
      backlog: 0,
      threshold_type: 'more',
      threshold: 3
    }
  })

  puts '==> Added stream "Catch all"'
end
