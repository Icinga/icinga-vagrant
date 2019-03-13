#    Copyright 2015 Mirantis, Inc.
#
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_notification).provide(:grafana, parent: Puppet::Provider::Grafana) do
  desc 'Support for Grafana notifications'

  defaultfor kernel: 'Linux'

  def grafana_api_path
    resource[:grafana_api_path]
  end

  def notifications
    response = send_request('GET', format('%s/alert-notifications', resource[:grafana_api_path]))
    if response.code != '200'
      raise format('Fail to retrieve notifications (HTTP response: %s/%s)', response.code, response.body)
    end

    begin
      notifications = JSON.parse(response.body)

      notifications.map { |x| x['id'] }.map do |id|
        response = send_request 'GET', format('%s/alert-notifications/%s', resource[:grafana_api_path], id)
        if response.code != '200'
          raise format('Failed to retrieve notification %d (HTTP response: %s/%s)', id, response.code, response.body)
        end

        notification = JSON.parse(response.body)

        {
          id: notification['id'],
          name: notification['name'],
          type: notification['type'],
          is_default: notification['isDefault'] ? :true : :false,
          send_reminder: notification['sendReminder'] ? :true : :false,
          frequency: notification['frequency'],
          settings: notification['settings']
        }
      end
    rescue JSON::ParserError
      raise format('Failed to parse response: %s', response.body)
    end
  end

  def notification
    unless @notification
      @notification = notifications.find { |x| x[:name] == resource[:name] }
    end
    @notification
  end

  attr_writer :notification

  def type
    notification[:type]
  end

  def type=(value)
    resource[:type] = value
    save_notification
  end

  # rubocop:disable Style/PredicateName
  def is_default
    notification[:is_default]
  end

  def is_default=(value)
    resource[:is_default] = value
    save_notification
  end

  def send_reminder
    notification[:send_reminder]
  end

  def send_reminder=(value)
    resource[:send_reminder] = value
    save_notification
  end
  # rubocop:enable Style/PredicateName

  def frequency
    notification[:frequency]
  end

  def frequency=(value)
    resource[:frequency] = value
    save_notification
  end

  def settings
    notification[:settings]
  end

  def settings=(value)
    resource[:settings] = value
    save_notification
  end

  def save_notification
    data = {
      name: resource[:name],
      type: resource[:type],
      isDefault: (resource[:is_default] == :true),
      sendReminder: (resource[:send_reminder] == :true),
      frequency: resource[:frequency],
      settings: resource[:settings]
    }

    if notification.nil?
      response = send_request('POST', format('%s/alert-notifications', resource[:grafana_api_path]), data)
    else
      data[:id] = notification[:id]
      response = send_request 'PUT', format('%s/alert-notifications/%s', resource[:grafana_api_path], notification[:id]), data
    end
    if response.code != '200'
      raise format('Failed to create save %s (HTTP response: %s/%s)', resource[:name], response.code, response.body)
    end
    self.notification = nil
  end

  def delete_notification
    response = send_request 'DELETE', format('%s/alert-notifications/%s', resource[:grafana_api_path], notification[:id])

    if response.code != '200'
      raise format('Failed to delete notification %s (HTTP response: %s/%s', resource[:name], response.code, response.body)
    end
    self.notification = nil
  end

  def create
    save_notification
  end

  def destroy
    delete_notification
  end

  def exists?
    notification
  end
end
