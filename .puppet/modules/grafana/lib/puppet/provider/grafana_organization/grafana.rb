require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_organization).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana organizations'

  defaultfor kernel: 'Linux'

  def organizations
    response = send_request('GET', format('%s/orgs', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Failed to retrieve organizations (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      organizations = JSON.parse(response.body)

      organizations.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/orgs/%s', resource[:grafana_api_path], id)
        if response.code != '200'
          raise format('Failed to retrieve organization %d (HTTP response: %s/%s)', id, response.code, response.body)
        end

        organization = JSON.parse(response.body)

        {
          id: organization['id'],
          name: organization['name'],
          address: organization['address']
        }
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
    end
  end

  def organization
    unless @organization
      @organization = organizations.find { |x| x[:name] == resource[:name] }
    end
    @organization
  end

  attr_writer :organization

  # rubocop:enable Style/PredicateName

  def id
    organization[:id]
  end

  def id=(value)
    resource[:id] = value
    save_organization
  end

  def address
    organization[:json_data]
  end

  def address=(value)
    resource[:address] = value
    save_organization
  end

  def save_organization
    data = {
      id: resource[:id],
      name: resource[:name],
      address: resource[:address]
    }

    response = send_request('POST', format('%s/orgs', resource[:grafana_api_path]), data) if organization.nil?

    if response.code != '200'
      raise format('Failed to create save %s (HTTP response: %s/%s)', resource[:name], response.code, response.body)
    end
    self.organization = nil
  end

  def delete_organization
    response = send_request 'DELETE', format('%s/orgs/%s', resource[:grafana_api_path], organization[:id])

    if response.code != '200'
      raise format('Failed to delete organization %s (HTTP response: %s/%s)', resource[:name], response.code, response.body)
    end
    self.organization = nil
  end

  def create
    save_organization
  end

  def destroy
    delete_organization
  end

  def exists?
    organization
  end
end
