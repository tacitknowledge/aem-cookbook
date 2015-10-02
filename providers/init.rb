#
# Cookbook Name:: aem
# Provider:: init
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

# This provider creates an init script for AEM

action :add do
  vars = {}
  service_name = new_resource.service_name
  var_list = [
    :aem_options, :default_context, :runnable_jar, :base_dir, :jvm_opts, :jar_opts
  ]

  # take value passed to provider, or node attribute
  var_list.each do |var|
    vars[var] = new_resource.send(var) || node[:aem][var]
  end
  template "/etc/init.d/#{service_name}" do
    cookbook 'aem'
    source 'init.erb'
    mode '0755'
    variables(vars)
    notifies :restart, resources(service: "#{service_name}")
  end
end
