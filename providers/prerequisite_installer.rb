#
# Cookbook Name:: aem
# Provider:: prerequisite_installer
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

action :install do
	vars = {}	
	var_list = [:base_dir, :install_pkgs_on_start, :package_store_url]

	# take value passed to provider, or node attribute
	var_list.each do |var|
	vars[var] = new_resource.send(var) || node[:aem][var]
	end

	directory "#{vars[:base_dir]}/install" do
	  recursive false
	  owner 'crx'
	  group 'crx'
	  mode '0755'
	  action :create
	end
	
	# vars[:install_pkgs_on_start].each do |f|   
 #      remote_name = f
	#   r = remote_file "#{Chef::Config[:file_cache_path]}/#{remote_name}" do
	#       source "#{vars[:package_store_url]}/#{f}"
	#       mode '0755'
	#       action :nothing
 #      end
 #      r.run_action(:create_if_missing)

 #      remote_file "#{vars[:base_dir]}/install/#{f}" do
	#     source "file://#{Chef::Config[:file_cache_path]}/#{remote_name}"
	#     owner 'crx'
	#     group 'crx'
	#     mode '0755'
	#     action :create_if_missing
 #      end   
 #    end
 vars[:install_pkgs_on_start].each do |f|
   remote_file "#{vars[:base_dir]}/install/#{f}" do
      source "#{vars[:package_store_url]}/#{f}"
      owner 'crx'
      group 'crx'
      mode "0644"
      action :create_if_missing
   end
 end
end

