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

  # Return the list of dashboards
  def dashboards
    response = send_request('GET', '/api/search', nil, q: '', starred: false)
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

    response = send_request('GET', format('/api/dashboards/db/%s', slug))
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
    data = {
      dashboard: dashboard.merge('title' => resource[:title],
                                 'id' => @dashboard ? @dashboard['id'] : nil,
                                 'version' => @dashboard ? @dashboard['version'] + 1 : 0),
      overwrite: !@dashboard.nil?
    }

    response = send_request('POST', '/api/dashboards/db', data)
    return unless response.code != '200'
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
    response = send_request('DELETE', format('/api/dashboards/db/%s', slug))

    return unless response.code != '200'
    raise Puppet::Error, format('Failed to delete dashboard %s (HTTP response: %s/%s', resource[:title], response.code, response.body)
  end

  def exists?
    find_dashboard
  end
end
