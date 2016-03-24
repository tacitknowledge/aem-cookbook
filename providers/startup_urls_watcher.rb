#
# Cookbook Name:: aem
# Provider:: startup_urls_watcher
#
# Copyright 2016, Critical Mass, Inc.
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

# This provider creates a resource that monitors a collection of validation urls on a newly started aem instance

action :wait do
  instance_name = new_resource.instance_name
  if node[:aem][:version].to_f > 5.4
    node['aem'][instance_name]['validation_urls'].each do |url|
      aem_url_watcher url do
        validation_url url
        status_command "service aem-#{instance_name} status | grep running"
        max_attempts node['aem'][instance_name]['startup']['max_attempts']
        wait_between_attempts node['aem'][instance_name]['startup']['wait_between_attempts']
        user node['aem'][instance_name]['admin_user']
        password node['aem'][instance_name]['admin_password']
        action :wait
      end
    end
  else
    aem_port_watcher node['aem'][instance_name][port] do
      status_command "service aem-#{instance_name} status | grep running"
      action :wait
    end
  end
end