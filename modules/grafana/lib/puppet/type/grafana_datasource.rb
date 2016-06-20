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
Puppet::Type.newtype(:grafana_datasource) do
    @doc = "Manage datasources in Grafana"

    ensurable

    newparam(:name, :namevar => true) do
        desc "The name of the datasource."
    end

    newparam(:grafana_url) do
        desc "The URL of the Grafana server"
        defaultto ""

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid URL" % value
            end
        end
    end

    newparam(:grafana_user) do
        desc "The username for the Grafana server"
    end

    newparam(:grafana_password) do
        desc "The password for the Grafana server"
    end

    newproperty(:url) do
        desc "The URL of the datasource"

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid URL" % value
            end
        end
    end

    newproperty(:type) do
        desc "The datasource type"
        newvalues(:influxdb, :elasticsearch, :graphite, :kairosdb, :opentsdb, :prometheus)
    end

    newproperty(:user) do
        desc "The username for the datasource (optional)"
    end

    newproperty(:password) do
        desc "The password for the datasource (optional)"
    end

    newproperty(:database) do
        desc "The name of the database (optional)"
    end

    newproperty(:access_mode) do
        desc "Whether the datasource is accessed directly or not by the clients"
        newvalues(:direct, :proxy)
        defaultto :direct
    end

    newproperty(:is_default) do
        desc "Whether the datasource is the default one"
        newvalues(:true, :false)
        defaultto :false
    end

    newproperty(:json_data) do
        desc "Additional JSON data to configure the datasource (optional)"

        validate do |value|
            unless value.nil? or value.is_a?(Hash) then
                raise ArgumentError , "json_data should be a Hash!"
            end
        end
    end
    autorequire(:service) do
      'grafana-server'
    end
end
