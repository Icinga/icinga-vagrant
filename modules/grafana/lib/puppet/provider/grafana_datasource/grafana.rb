#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

Puppet::Type.type(:grafana_datasource).provide(:grafana, :parent => Puppet::Provider::Grafana) do
    desc "Support for Grafana datasources"

    defaultfor :kernel => 'Linux'

    def datasources
        response = self.send_request('GET', '/api/datasources')
        if response.code != '200'
            fail("Fail to retrieve datasources (HTTP response: %s/%s)" %
                 [response.code, response.body])
        end

        begin
            datasources = JSON.parse(response.body)

            datasources.collect{|x| x["id"]}.collect do |id|
                response = self.send_request('GET', '/api/datasources/%s' % id)
                if response.code != '200'
                    fail("Fail to retrieve datasource %d (HTTP response: %s/%s)" %
                         [id, response.code, response.body])
                end

                datasource = JSON.parse(response.body)

                {
                    :id => datasource["id"],
                    :name => datasource["name"],
                    :url => datasource["url"],
                    :type => datasource["type"],
                    :user => datasource["user"],
                    :password => datasource["password"],
                    :database => datasource["database"],
                    :access_mode => datasource["access"],
                    :is_default => datasource["isDefault"] ? :true : :false,
                    :json_data => datasource["jsonData"]
                }
            end
        rescue JSON::ParserError
            fail("Fail to parse response: %s" % response.body)
        end
    end

    def datasource
        unless @datasource
            @datasource = self.datasources.find { |x| x[:name] == resource[:name] }
        end
        @datasource
    end

    def datasource=(value)
        @datasource = value
    end

    def type
        self.datasource[:type]
    end

    def type=(value)
        resource[:type] = value
        self.save_datasource()
    end

    def url
        self.datasource[:url]
    end

    def url=(value)
        resource[:url] = value
        self.save_datasource()
    end

    def access_mode
        self.datasource[:access_mode]
    end

    def access_mode=(value)
        self.resource[:access_mode] = value
        self.save_datasource()
    end

    def database
        self.datasource[:database]
    end

    def database=(value)
        resource[:database] = value
        self.save_datasource()
    end

    def user
        self.datasource[:user]
    end

    def user=(value)
        resource[:user] = value
        self.save_datasource()
    end

    def password
        self.datasource[:password]
    end

    def password=(value)
        resource[:password] = value
        self.save_datasource()
    end

    def is_default
        self.datasource[:is_default]
    end

    def is_default=(value)
        resource[:is_default] = value
        self.save_datasource()
    end

    def json_data
        self.datasource[:json_data]
    end

    def json_data=(value)
        resource[:json_data] = value
        self.save_datasource()
    end

    def save_datasource
        data = {
            :name => resource[:name],
            :type => resource[:type],
            :url => resource[:url],
            :access => resource[:access_mode],
            :database => resource[:database],
            :user => resource[:user],
            :password => resource[:password],
            :isDefault => (resource[:is_default] == :true),
            :jsonData => resource[:json_data],
        }

        if self.datasource.nil?
            response = self.send_request('POST', '/api/datasources', data)
        else
            data[:id] = self.datasource[:id]
            response = self.send_request('PUT', '/api/datasources/%s' % self.datasource[:id], data)
        end

        if response.code != '200'
            fail("Failed to create save '%s' (HTTP response: %s/'%s')" %
                [resource[:name], response.code, response.body])
        end
        self.datasource = nil
    end

    def delete_datasource
        response = self.send_request('DELETE', '/api/datasources/%s' % self.datasource[:id])

        if response.code != '200'
            fail("Failed to delete datasource '%s' (HTTP response: %s/'%s')" %
                [resource[:name], response.code, response.body])
        end
        self.datasource = nil
    end

    def create
        self.save_datasource()
    end

    def destroy
        self.delete_datasource()
    end

    def exists?
        self.datasource
    end
end
