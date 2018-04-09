#
# Cookbook Name:: aem
# Provider:: farm
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

# This provider creates or removes a farm_*.any file for AEM dispatcher

action :add do
  farm_name = new_resource.farm_name
  vars = {}
  # need the right kind of "empty"
  var_list = { client_headers: :array, virtual_hosts: :array,
               renders: :array, statistics: :array,
               filter_rules: :hash, cache_rules: :hash,
               invalidation_rules: :hash, allowed_clients: :hash,
               ignore_url_params: :hash,
               cache_root: :scalar, farm_dir: :scalar,
               farm_name: :scalar, cache_opts: :array,
               session_mgmt: :hash, enable_session_mgmt: :scalar }
  empty = { array: [], hash: {}, scalar: nil }

  # take value passed to provider, or node attribute, or empty
  var_list.keys.each do |var|
    type = var_list[var]
    nothing = empty[type]
    vars[var] = new_resource.send(var) || node[:aem][:dispatcher][var] || nothing
  end

  fail 'farm_dir attribute is required to create a farm.' unless vars[:farm_dir]

  # If this is a dynamic cluster, search the chef database for the members
  if new_resource.dynamic_cluster
    vars[:renders] = []
    role = new_resource.cluster_role
    cluster_name = new_resource.cluster_name
    cluster_type = new_resource.cluster_type
    timeout = new_resource.render_timeout

    search_criteria = AEM::Helpers.build_cluster_search_criteria(role, cluster_name)
    renders = search(:node, search_criteria)

    # Don't want to rely on what order the search results come back in
    renders.sort! { |a, b| a[:hostname] <=> b[:hostname] }
    renders.each do |r|
      unless r[:aem][cluster_type]
        fail "Node #{r[:fqdn]} attribute :aem=>:#{cluster_type}=>:port does not exist"
      end
      vars[:renders] << {
        name: r[:fqdn],
        hostname: r[:ipaddress],
        port: r[:aem][cluster_type][:port],
        timeout: timeout
      }
    end
    # Don't ever return an empty renders list, or apache won't start and
    # subsequent chef runs will fail.
    if vars[:renders].empty?
      vars[:renders] << {
        name: 'NoClusterMembersFound',
        hostname: 'localhost',
        port: '4503',
        timeout: '1'
      }
    end
  end

  template "#{vars[:farm_dir]}/farm_#{farm_name}.any" do
    cookbook new_resource.farm_template_cookbook
    source new_resource.farm_template_source
    group node[:apache][:root_group]
    mode '0664'
    variables(vars)
    notifies :restart, resources(service: 'apache2')
  end
end

action :remove do
  farm_name = new_resource.farm_name || node[:aem][:dispatcher][:farm_name]
  farm_dir = new_resource.farm_dir || node[:aem][:dispatcher][:farm_dir]
  file "#{farm_dir}/farm_#{farm_name}.any" do
    action :delete
    notifies :restart, resources(service: 'apache2')
  end
end
