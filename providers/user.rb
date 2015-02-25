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

#This provider changes a users password for an AEM instance

require 'erb'

def set_vars
  user = new_resource.user
  password = new_resource.password
  admin_user = new_resource.admin_user
  admin_password = new_resource.admin_password
  port = new_resource.port
  aem_version = new_resource.aem_version
  #By default, AEM will put users in a folder named for their first letter
  path = new_resource.path || "/home/users/#{user[0]}"
  group = new_resource.group
  [ user, password, admin_user, admin_password, port, aem_version, path, group ]
end

action :set_password do


  user,password,admin_user,admin_password,port,aem_version,path,group = set_vars
  

  case
  when aem_version.to_f >= 6.0
    cmd = ERB.new(node[:aem][:commands][:password][:aem60]).result(binding)
  when aem_version.to_f > 5.4
    cmd = ERB.new(node[:aem][:commands][:password][:aem55]).result(binding)
  else 
    cmd = ERB.new(node[:aem][:commands][:password][:aem54]).result(binding)
  end

  runner = Mixlib::ShellOut.new(cmd)
  runner.run_command
  runner.error!
end

action :remove do

  user,password,admin_user,admin_password,port,aem_version,path,group = set_vars

  if aem_version.to_f > 5.4
    cmd = ERB.new(node[:aem][:commands][:remove_user][:aem55]).result(binding)
  else
    raise "Action aem_user :remove is not implemented for AEM < 5.5.  If you know the proper curl command, please implement it in the provider."
  end

  runner = Mixlib::ShellOut.new(cmd)
  runner.run_command
  runner.error!
end

action :add do

  user,password,admin_user,admin_password,port,aem_version,path,group = set_vars

  if aem_version.to_f > 5.4
    cmd = ERB.new(node[:aem][:commands][:add_user][:aem55]).result(binding)
  else
    raise "Action aem_user :add is not implemented for AEM < 5.5.  If you know the proper curl command, please implement it in the provider."
  end

  runner = Mixlib::ShellOut.new(cmd)
  runner.run_command
  runner.error!
end
