#
# Cookbook Name:: aem
# Provider:: website
#
# Copyright 2012, Tacit Knowledge, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This provider creates or removes an apache virtual host containing locations
# served by dispatcher.

action :add do
  site_name = new_resource.site_name
  vars = {}
  var_list = [
    :site_name, :server_name, :server_aliases, :aem_locations, :cache_root,
    :enabled, :rewrites, :listen_port, :ssl_enabled, :ssl_cert_file,
    :ssl_key_file, :expire_dirs, :enable_etag, :enable_ie_header,
    :template_cookbook, :template_name, :deflate_enabled, :local_vars, :header
  ]
  var_list.each do |var|
    vars[var] = new_resource.send(var) || node[:aem][:dispatcher][var]
  end

  directory vars[:cache_root] do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end

  # from apache2/definitions
  web_app site_name do
    template vars[:template_name]
    server_name vars[:server_name]
    server_aliases vars[:server_aliases]
    docroot vars[:cache_root]
    aem_locations vars[:aem_locations]
    rewrites vars[:rewrites]
    listen_port vars[:listen_port]
    ssl_enabled vars[:ssl_enabled]
    ssl_cert_file vars[:ssl_cert_file]
    ssl_key_file vars[:ssl_key_file]
    expire_dirs vars[:expire_dirs]
    enable_etag vars[:enable_etag]
    enable_ie_header vars[:enable_ie_header]
    cookbook vars[:template_cookbook]
    deflate_enabled vars[:deflate_enabled]
    local_vars vars[:local_vars]
    enable vars[:enabled]
    header vars[:header]
  end
end

action :remove do
  apache_site "#{new_resource.site_name}.conf" do
    enable false
  end
end
