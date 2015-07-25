#
# Cookbook Name:: aem
# Provider:: document_node_store_service_cfg
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

# This provider creates a crx-quickststart/install config file for org.apache.jackrabbit.oak.plugins.document.DocumentNodeStoreService.cfg

action :add do
  vars = {}
  service_name = new_resource.service_name
  base_dir = new_resource.base_dir
  var_list = [
    :base_dir
  ]

  #take value passed to provider, or node attribute
  var_list.each do |var|
    vars[var] = new_resource.send(var) || node[:aem][var]
  end
  template "#{base_dir}/install/org.apache.jackrabbit.oak.plugins.document.DocumentNodeStoreService.cfg" do
    cookbook 'aem'
    source 'org.apache.jackrabbit.oak.plugins.document.DocumentNodeStoreService.cfg.erb'
    mode '0755'
    variables(vars)
  end
end
