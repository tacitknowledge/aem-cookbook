#
# Cookbook Name:: aem
# Provider:: group
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

require 'erb'

def set_vars
  group = new_resource.group
  admin_user = new_resource.admin_user
  admin_password = new_resource.admin_password
  port = new_resource.port
  aem_version = new_resource.aem_version
  #By default, AEM will put groups in a folder named for their first letter (prior to AEM 6.x)
  path = new_resource.path || "/home/groups/#{group[0]}"
  [ group, admin_user, admin_password, port, aem_version, path ]
end

def curl(url, user, password)
  c = Curl::Easy.new(url)
  c.http_auth_types = :basic
  c.username = user
  c.password = password
  c.perform
  c
end

def get_group_path(port, group, admin_user, admin_password)
  url = "http://localhost:#{port}/bin/querybuilder.json?path=/home/groups&1_property=rep:authorizableId&1_property.value=#{group}&p.limit=-1"
  c = curl(url, admin_user, admin_password)
  group_json = JSON.parse(c.body_str)

  path = nil
  hits = group_json['hits']
  if hits.empty?
    Chef::Log.warn("Unable to find path for group [#{group}]. Does this group exist?")
  else
    path = hits.first['path']
    Chef::Log.info("Found path for group [#{group}]: [#{path}]")
  end
  path
end

action :remove do
  group, admin_user, admin_password, port, aem_version, path = set_vars

  perform_action = true
  case
  when aem_version.to_f >= 6.1
    path = get_group_path(port, group, admin_user, admin_password)

    if path.nil?
      Chef::Log.warn("Group [#{group}] doesn't exist; cannot remove group.")
      perform_action = false
    end
  else
    perform_action = false
    Chef::Log.warn('The aem_group provider only works with AEM 6.1 and higher.')
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:remove_group], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end

action :add do
  group, admin_user, admin_password, port, aem_version, path = set_vars

  perform_action = true
  case
  when aem_version.to_f >= 6.1
    perform_action = true
  else
    perform_action = false
    Chef::Log.warn('The aem_group provider only works with AEM 6.1 and higher.')
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:add_group], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end

action :add_user do
  group, admin_user, admin_password, port, aem_version, path = set_vars
  user = new_resource.user

  perform_action = true
  case
  when aem_version.to_f >= 6.1
    path = get_group_path(port, group, admin_user, admin_password)

    if path.nil?
      Chef::Log.warn("Group [#{group}] doesn't exist; cannot add user [#{user}] to group.")
      perform_action = false
    end
  else
    perform_action = false
    Chef::Log.warn('The aem_group provider only works with AEM 6.1 and higher.')
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:add_user_to_group], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end

action :remove_user do
  group, admin_user, admin_password, port, aem_version, path = set_vars
  user = new_resource.user

  perform_action = true
  case
  when aem_version.to_f >= 6.1
    path = get_group_path(port, group, admin_user, admin_password)

    if path.nil?
      Chef::Log.warn("Group [#{group}] doesn't exist; cannot remove user [#{user}] from group.")
      perform_action = false
    end
  else
    perform_action = false
    Chef::Log.warn('The aem_group provider only works with AEM 6.1 and higher.')
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:remove_user_from_group], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end
