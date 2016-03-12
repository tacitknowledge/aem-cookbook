#
# Cookbook Name:: aem
# Provider:: password
#
# Copyright 2012-2013, Tacit Knowledge, Inc.
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

# This provider changes a users password for an AEM instance

require 'erb'

def set_vars
  user = new_resource.user
  password = new_resource.password
  admin_user = new_resource.admin_user
  admin_password = new_resource.admin_password
  port = new_resource.port
  aem_version = new_resource.aem_version
  # By default, AEM will put users in a folder named for their first letter (prior to AEM 6.x)
  path = new_resource.path || "/home/users/#{user[0]}"
  group = new_resource.group
  [user, password, admin_user, admin_password, port, aem_version, path, group]
end

def curl(url, user, password)
  c = Curl::Easy.new(url)
  c.http_auth_types = :basic
  c.username = user
  c.password = password
  c.perform
  c
end

def get_usr_path(port, user, admin_user, admin_password)
  url_user = "http://localhost:#{port}/bin/querybuilder.json?path=/home/users&1_property=rep:authorizableId&1_property.value=#{user}&p.limit=-1"
  c = curl(url_user, admin_user, admin_password)
  usr_json = JSON.parse(c.body_str)

  path = nil
  hits = usr_json['hits']
  if hits.empty?
    Chef::Log.warn("Unable to find path for user [#{user}]. Does this user exist?")
  else
    path = hits.first['path']
    Chef::Log.info("Found path for user [#{user}]: [#{path}]")
  end
  path
end

action :set_password do
  user, password, admin_user, admin_password, port, aem_version, path, group = set_vars

  perform_action = true

  case
  when aem_version.to_f >= 6.1
    path = get_usr_path(port, user, admin_user, admin_password)

    if path.nil?
      Chef::Log.warn("User [#{user}] doesn't exist; cannot set password.")
      perform_action = false
    end
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:password], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end

action :remove do
  user, password, admin_user, admin_password, port, aem_version, path, group = set_vars

  perform_action = true

  case
  when aem_version.to_f >= 6.1
    path = get_usr_path(port, user, admin_user, admin_password)

    if path.nil?
      Chef::Log.warn("User [#{user}] doesn't exist; cannot remove user.")
      perform_action = false
    end
  end

  if perform_action
    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:remove_user], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
  end
end

action :add do
  user, password, admin_user, admin_password, port, aem_version, path, group = set_vars

  aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:add_user], aem_version)
  cmd = ERB.new(aem_command).result(binding)

  runner = Mixlib::ShellOut.new(cmd)
  runner.run_command
  runner.error!

  case
  when aem_version.to_f >= 6.1
    unless group.nil?
      aem_group group do
        admin_user admin_user
        admin_password admin_password
        port port
        aem_version aem_version
        user user
        action :add_user
      end
    end
  end

end
