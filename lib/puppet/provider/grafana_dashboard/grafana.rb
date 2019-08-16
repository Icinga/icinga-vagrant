#    Copyright 2015 Mirantis, Inc.
#
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

# Note: this class doesn't implement the self.instances and self.prefetch
# methods because the Grafana API doesn't allow to retrieve the dashboards and
# all their properties in a single call.
Puppet::Type.type(:grafana_dashboard).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana dashboards stored into Grafana'

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
      @fetch_organization =
        if resource[:organization].is_a?(Numeric) || resource[:organization].match(%r{^[0-9]*$})
          fetch_organizations.find { |x| x[:id] == resource[:organization] }
        else
          fetch_organizations.find { |x| x[:name] == resource[:organization] }
        end
    end
    @fetch_organization
  end

  def folders
    response = send_request('GET', format('%s/folders', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve the folders (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      @folders = JSON.parse(response.body)
    rescue JSON::ParserError
      raise format('Fail to parse folders (HTTP response: %s/%s)', response.code, response.body)
    end
  end

  def find_folder
    folders unless @folders

    begin
      @folders.each do |folder|
        @folder = folder if folder['title'] == resource[:folder]
      end
      raise format('Folder not found: %s', resource[:folder]) unless @folder['title'] == resource[:folder]
    rescue JSON::ParserError
      raise format('Fail to parse folder %s: %s', resource[:folder], response.body)
    end
  end

  # Return the list of dashboards
  def dashboards
    response = send_request('GET', format('%s/search', resource[:grafana_api_path]), nil, q: '', starred: false)
    if response.code != '200'
      raise format('Fail to retrieve the dashboards (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise format('Fail to parse dashboards (HTTP response: %s/%s)', response.code, response.body)
    end
  end

  # Return the dashboard matching with the resource's title
  def find_dashboard
    return unless dashboards.find { |x| x['title'] == resource[:title] }

    response = send_request('GET', format('%s/dashboards/db/%s', resource[:grafana_api_path], slug))
    if response.code != '200'
      raise format('Fail to retrieve dashboard %s (HTTP response: %s/%s)', resource[:title], response.code, response.body)
    end

    begin
      # Cache the dashboard's content
      @dashboard = JSON.parse(response.body)['dashboard']
    rescue JSON::ParserError
      raise format('Fail to parse dashboard %s: %s', resource[:title], response.body)
    end
  end

  def save_dashboard(dashboard)
    find_folder if resource[:folder]

    # change organizations
    response = send_request 'POST', format('%s/user/using/%s', resource[:grafana_api_path], fetch_organization[:id])
    unless response.code == '200'
      raise format('Failed to switch to org %s (HTTP response: %s/%s)', fetch_organization[:id], response.code, response.body)
    end

    data = {
      dashboard: dashboard.merge('title' => resource[:title],
                                 'id' => @dashboard ? @dashboard['id'] : nil,
                                 'version' => @dashboard ? @dashboard['version'] + 1 : 0),
      folderId: @folder ? @folder['id'] : nil,
      overwrite: !@dashboard.nil?
    }

    response = send_request('POST', format('%s/dashboards/db', resource[:grafana_api_path]), data)
    return unless (response.code != '200') && (response.code != '412')
    raise format('Fail to save dashboard %s (HTTP response: %s/%s', resource[:name], response.code, response.body)
  end

  def slug
    resource[:title].downcase.gsub(%r{[ \+]+}, '-').gsub(%r{[^\w\- ]}, '')
  end

  def content
    @dashboard.reject { |k, _| k =~ %r{^id|version|title$} }
  end

  def content=(value)
    save_dashboard(value)
  end

  def create
    save_dashboard(resource[:content])
  end

  def destroy
    response = send_request('DELETE', format('%s/dashboards/db/%s', resource[:grafana_api_path], slug))

    return unless response.code != '200'
    raise Puppet::Error, format('Failed to delete dashboard %s (HTTP response: %s/%s', resource[:title], response.code, response.body)
  end

  def exists?
    find_dashboard
  end
end
