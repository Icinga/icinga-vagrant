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
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'grafana'))

# Note: this class doesn't implement the self.instances and self.prefetch
# methods because the Grafana API doesn't allow to retrieve the dashboards and
# all their properties in a single call.
Puppet::Type.type(:grafana_dashboard).provide(:grafana, :parent => Puppet::Provider::Grafana) do
    desc "Support for Grafana dashboards stored into Grafana"

    defaultfor :kernel => 'Linux'

    # Return the list of dashboards
    def dashboards
        response = self.send_request('GET', '/api/search', nil, {:q => '', :starred => false})
        if response.code != '200'
            fail("Fail to retrieve the dashboards (HTTP response: %s/%s)" %
                 [response.code, response.body])
        end

        begin
            JSON.parse(response.body)
        rescue JSON::ParserError
            fail("Fail to parse dashboards (HTTP response: %s/%s)" %
                 [response_code, response.body])
        end
    end

    # Return the dashboard matching with the resource's title
    def find_dashboard
        if not self.dashboards.find{ |x| x['title'] == resource[:title] }
            return
        end

        response = self.send_request('GET', '/api/dashboards/db/%s' % self.slug)
        if response.code != '200'
            fail("Fail to retrieve dashboard '%s' (HTTP response: %s/%s)" %
                 [resource[:title], response.code, response.body])
        end

        begin
            # Cache the dashboard's content
            @dashboard = JSON.parse(response.body)["dashboard"]
        rescue JSON::ParserError
            fail("Fail to parse dashboard '%s': %s" %
                 [resource[:title], response.body])
        end
    end

    def save_dashboard(dashboard)
        data = {
            :dashboard => dashboard.merge({
                'title' => resource[:title],
                'id' => @dashboard ? @dashboard['id'] : nil,
                'version' => @dashboard ? @dashboard['version'] + 1 : 0
            }),
            :overwrite => @dashboard != nil
        }

        response = self.send_request('POST', '/api/dashboards/db', data)
        if response.code != '200'
            fail("Fail to save dashboard '%s' (HTTP response: %s/%s)" %
                 [resource[:name], response.code, response.body])
        end
    end

    def slug
        resource[:title].downcase.gsub(/[^\w\- ]/, '').gsub(/ +/, '-')
    end

    def content
        @dashboard
    end

    def content=(value)
        self.save_dashboard(value)
    end

    def create
        self.save_dashboard(resource[:content])
    end

    def destroy
        response = self.send_request('DELETE', '/api/dashboards/db/%s' % self.slug)

        if response.code != '200'
            raise Puppet::Error, "Failed to delete dashboard '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:title], response.code,
                response.body]
        end
    end

    def exists?
        self.find_dashboard()
    end
end
