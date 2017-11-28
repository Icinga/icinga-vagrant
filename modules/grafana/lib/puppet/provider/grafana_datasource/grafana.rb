#    Copyright 2015 Mirantis, Inc.
#
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_datasource).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana datasources'

  defaultfor kernel: 'Linux'

  def datasources
    response = send_request('GET', '/api/datasources')
    if response.code != '200'
      raise format('Fail to retrieve datasources (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      datasources = JSON.parse(response.body)

      datasources.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('/api/datasources/%s', id)
        if response.code != '200'
          raise format('Fail to retrieve datasource %d (HTTP response: %s/%s)', id, response.code, response.body)
        end

        datasource = JSON.parse(response.body)

        {
          id: datasource['id'],
          name: datasource['name'],
          url: datasource['url'],
          type: datasource['type'],
          user: datasource['user'],
          password: datasource['password'],
          database: datasource['database'],
          access_mode: datasource['access'],
          is_default: datasource['isDefault'] ? :true : :false,
          json_data: datasource['jsonData']
        }
      end
    rescue JSON::ParserError
      raise format('Fail to parse response: %s', response.body)
    end
  end

  def datasource
    unless @datasource
      @datasource = datasources.find { |x| x[:name] == resource[:name] }
    end
    @datasource
  end

  attr_writer :datasource

  def type
    datasource[:type]
  end

  def type=(value)
    resource[:type] = value
    save_datasource
  end

  def url
    datasource[:url]
  end

  def url=(value)
    resource[:url] = value
    save_datasource
  end

  def access_mode
    datasource[:access_mode]
  end

  def access_mode=(value)
    resource[:access_mode] = value
    save_datasource
  end

  def database
    datasource[:database]
  end

  def database=(value)
    resource[:database] = value
    save_datasource
  end

  def user
    datasource[:user]
  end

  def user=(value)
    resource[:user] = value
    save_datasource
  end

  def password
    datasource[:password]
  end

  def password=(value)
    resource[:password] = value
    save_datasource
  end

  # rubocop:disable Style/PredicateName
  def is_default
    datasource[:is_default]
  end

  def is_default=(value)
    resource[:is_default] = value
    save_datasource
  end
  # rubocop:enable Style/PredicateName

  def json_data
    datasource[:json_data]
  end

  def json_data=(value)
    resource[:json_data] = value
    save_datasource
  end

  def save_datasource
    data = {
      name: resource[:name],
      type: resource[:type],
      url: resource[:url],
      access: resource[:access_mode],
      database: resource[:database],
      user: resource[:user],
      password: resource[:password],
      isDefault: (resource[:is_default] == :true),
      jsonData: resource[:json_data]
    }

    if datasource.nil?
      response = send_request('POST', '/api/datasources', data)
    else
      data[:id] = datasource[:id]
      response = send_request 'PUT', format('/api/datasources/%s', datasource[:id]), data
    end

    if response.code != '200'
      raise format('Failed to create save %s (HTTP response: %s/%s)', resource[:name], response.code, response.body)
    end
    self.datasource = nil
  end

  def delete_datasource
    response = send_request 'DELETE', format('/api/datasources/%s', datasource[:id])

    if response.code != '200'
      raise format('Failed to delete datasource %s (HTTP response: %s/%s', resource[:name], response.code, response.body)
    end
    self.datasource = nil
  end

  def create
    save_datasource
  end

  def destroy
    delete_datasource
  end

  def exists?
    datasource
  end
end
