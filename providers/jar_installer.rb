#
# Cookbook Name:: aem
# Provider:: jar_installer
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

# This provider installs AEM from a jar file at a URL

action :install do
  vars = {}
  service_name = new_resource.name
  var_list = [:download_url, :base_dir, :default_context, :port]

  # take value passed to provider, or node attribute
  var_list.each do |var|
    vars[var] = new_resource.send(var) || node[:aem][var]
  end

  jar_name = "aem-#{service_name}-p#{vars[:port]}.jar"

  directory vars[:base_dir] do
    owner 'crx'
    mode '0755'
  end

  directory vars[:default_context] do
    owner 'crx'
    mode '0755'
  end

  remote_jar_name = "aem-quickstart-#{node[:aem][:version]}.jar"
  r = remote_file "#{Chef::Config[:file_cache_path]}/#{remote_jar_name}" do
    source "#{vars[:download_url]}"
    mode '0755'
    action :nothing
  end
  r.run_action(:create_if_missing)

  remote_file "#{vars[:base_dir]}/#{service_name}/#{jar_name}" do
    source "file://#{Chef::Config[:file_cache_path]}/#{remote_jar_name}"
    mode '0755'
    action :create_if_missing
  end

  bash 'unpack jar' do
    user 'crx'
    cwd vars[:default_context]
    code "java -jar #{jar_name} -unpack"
  end unless Object::File.exists?("#{vars[:default_context]}/#{node[:aem][:unpack_jar_dir]}")
end
