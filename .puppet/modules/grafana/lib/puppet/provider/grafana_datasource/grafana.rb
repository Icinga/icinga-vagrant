#    Copyright 2015 Mirantis, Inc.
#
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_datasource).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana datasources'

  defaultfor kernel: 'Linux'

  def organization
    resource[:organization]
  end

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def fetch_organizations
    response = send_request('GET', format('%s/orgs', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve organizations (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      fetch_organizations = JSON.parse(response.body)
      fetch_organizations.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/orgs/%s', resource[:grafana_api_path], id)
        if response.code != '200'
          raise format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body)
        end

        fetch_organization = JSON.parse(response.body)

        {
          id: fetch_organization['id'],
          name: fetch_organization['name']
        }
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
    end
  end

  def fetch_organization
    unless @fetch_organization
      @fetch_organization = if resource[:organization].is_a?(Numeric) || resource[:organization].match(%r{^[0-9]*$})
                              fetch_organizations.find { |x| x[:id] == resource[:organization] }
                            else
                              fetch_organizations.find { |x| x[:name] == resource[:organization] }
                            end
    end
    @fetch_organization
  end

  def datasources
    response = send_request('GET', format('%s/datasources', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve datasources (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      datasources = JSON.parse(response.body)

      datasources.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/datasources/%s', resource[:grafana_api_path], id)
        if response.code != '200'
          raise format('Failed to retrieve datasource %d (HTTP response: %s/%s)', id, response.code, response.body)
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
          with_credentials: datasource['withCredentials'] ? :true : :false,
          basic_auth: datasource['basicAuth'] ? :true : :false,
          basic_auth_user: datasource['basicAuthUser'],
          basic_auth_password: datasource['basicAuthPassword'],
          json_data: datasource['jsonData'],
          secure_json_data: datasource['secureJsonData']
        }
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
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

  def basic_auth
    datasource[:basic_auth]
  end

  def basic_auth=(value)
    resource[:basic_auth] = value
    save_datasource
  end

  def basic_auth_user
    datasource[:basic_auth_user]
  end

  def basic_auth_user=(value)
    resource[:basic_auth_user] = value
    save_datasource
  end

  def basic_auth_password
    datasource[:basic_auth_password]
  end

  def basic_auth_password=(value)
    resource[:basic_auth_password] = value
    save_datasource
  end

  def with_credentials
    datasource[:with_credentials]
  end

  def with_credentials=(value)
    resource[:with_credentials] = value
    save_datasource
  end

  def json_data
    datasource[:json_data]
  end

  def json_data=(value)
    resource[:json_data] = value
    save_datasource
  end

  def secure_json_data
    datasource[:secure_json_data]
  end

  def secure_json_data=(value)
    resource[:secure_json_data] = value
    save_datasource
  end

  def save_datasource
    # change organizations
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], fetch_organization[:id])
    unless response.code == '200'
      raise format('Failed to switch to org %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body)
    end

    data = {
      name: resource[:name],
      type: resource[:type],
      url: resource[:url],
      access: resource[:access_mode],
      database: resource[:database],
      user: resource[:user],
      password: resource[:password],
      isDefault: (resource[:is_default] == :true),
      basicAuth: (resource[:basic_auth] == :true),
      basicAuthUser: resource[:basic_auth_user],
      basicAuthPassword: resource[:basic_auth_password],
      withCredentials: (resource[:with_credentials] == :true),
      jsonData: resource[:json_data],
      secureJsonData: resource[:secure_json_data]
    }

    if datasource.nil?
      response = send_request('POST', format('%s/datasources', resource[:grafana_api_path]), data)
    else
      data[:id] = datasource[:id]
      response = send_request 'PUT', format('%s/datasources/%s', resource[:grafana_api_path], datasource[:id]), data
    end
    if response.code != '200'
      raise format('Failed to create save %s (HTTP response: %s/%s)', resource[:name], response.code, response.body)
    end
    self.datasource = nil
  end

  def delete_datasource
    response = send_request 'DELETE', format('%s/datasources/%s', resource[:grafana_api_path], datasource[:id])

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
