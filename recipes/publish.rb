#
# Cookbook Name:: aem
# Recipe:: publish
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

include_recipe 'aem::_base_aem_setup'

unless node[:aem][:use_yum]
  aem_jar_installer 'publish' do
    download_url node[:aem][:download_url]
    default_context node[:aem][:publish][:default_context]
    port node[:aem][:publish][:port]
    action :install
  end
end

unless node[:aem][:license_url].nil?
  remote_file "#{node[:aem][:publish][:default_context]}/license.properties" do
    source "#{node[:aem][:license_url]}"
    sensitive true
    mode 0644
  end
end

unless node[:aem][:license_customer_name].nil? && node[:aem][:license_download_id].nil?
  template "#{node[:aem][:publish][:default_context]}/license.properties" do
    source 'license.properties.erb'
    sensitive true
    mode 0644
  end
end

if node[:aem][:version].to_f > 5.4
  node.set[:aem][:publish][:runnable_jar] = "aem-publish-p#{node[:aem][:publish][:port]}.jar"
end

aem_init 'aem-publish' do
  service_name 'aem-publish'
  default_context node[:aem][:publish][:default_context]
  runnable_jar node[:aem][:publish][:runnable_jar]
  base_dir node[:aem][:publish][:base_dir]
  jvm_opts node[:aem][:publish][:jvm_opts]
  jar_opts node[:aem][:publish][:jar_opts]
  action :add
end

service 'aem-publish' do
  # init script returns 0 for status no matter what
  status_command 'service aem-publish status | grep running'
  supports status: true, stop: true, start: true, restart: true
  action [:enable, :start]
end

if node[:aem][:version].to_f > 5.4
  node[:aem][:publish][:validation_urls].each do |url|
    aem_url_watcher url do
      validation_url url
      status_command 'service aem-publish status | grep running'
      max_attempts node[:aem][:publish][:startup][:max_attempts]
      wait_between_attempts node[:aem][:publish][:startup][:wait_between_attempts]
      user node[:aem][:publish][:admin_user]
      password node[:aem][:publish][:admin_password]
      action :wait
    end
  end
else
  aem_port_watcher '4503' do
    status_command 'service aem-publish status | grep running'
    action :wait
  end
end

unless node[:aem][:publish][:new_admin_password].nil?
  # Change admin password
  aem_user node[:aem][:publish][:admin_user] do
    password node[:aem][:publish][:new_admin_password]
    admin_user node[:aem][:publish][:admin_user]
    admin_password node[:aem][:publish][:admin_password]
    port node[:aem][:publish][:port]
    aem_version node[:aem][:version]
    action :set_password
  end

  node.set[:aem][:publish][:admin_password] = node[:aem][:publish][:new_admin_password]
  node.set[:aem][:publish][:new_admin_password] = nil
end

# delete the privileged users from geometrixx, if they're still there.
node[:aem][:geometrixx_priv_users].each do |user|
  aem_user user do
    admin_user node[:aem][:publish][:admin_user]
    admin_password lazy { node[:aem][:publish][:admin_password] }
    port node[:aem][:publish][:port]
    aem_version node[:aem][:version]
    path '/home/users/geometrixx'
    action :remove
  end
end

aem_ldap 'publish' do
  options node[:aem][:publish][:ldap][:options]
  action node[:aem][:publish][:ldap][:enabled] ? :enable : :disable
end

if node[:aem][:version].to_f < 5.5
  web_inf_dir = "#{node[:aem][:publish][:base_dir]}/server/runtime/0/_crx/WEB-INF"
  log "ABOUT TO CREATE DIR: #{web_inf_dir}"
  user = node[:aem][:aem_options]['RUNAS_USER']
  directory web_inf_dir do
    owner user
    group user
    mode '0755'
    action :create
    recursive true
  end
  template "#{web_inf_dir}/web.xml" do
    source 'web.xml.erb'
    owner user
    group user
    mode '0644'
    action :create
    notifies :restart, 'service[aem-publish]'
  end
end

# If we're using the aem_package provider to deploy, do it now
node[:aem][:publish][:deploy_pkgs].each do |pkg|
  aem_package pkg[:name] do
    version pkg[:version]
    aem_instance 'publish'
    package_url pkg[:url]
    update pkg[:update]
    user node[:aem][:publish][:admin_user]
    password lazy { node[:aem][:publish][:admin_password] }
    port node[:aem][:publish][:port]
    group_id pkg[:group_id]
    recursive pkg[:recursive]
    properties_file pkg[:properties_file]
    version_pattern pkg[:version_pattern]
    action pkg[:action]
  end
end

# Create cache flush agents
aem_replicator 'create_flush_agents' do
  local_user node[:aem][:publish][:admin_user]
  local_password lazy { node[:aem][:publish][:admin_password] }
  local_port node[:aem][:publish][:port]
  remote_hosts node[:aem][:publish][:cache_hosts]
  dynamic_cluster node[:aem][:publish][:find_cache_hosts_dynamically]
  cluster_name node[:aem][:cluster_name]
  cluster_role node[:aem][:dispatcher][:cluster_role]
  aem_version node[:aem][:version]
  type :flush_agent
  action :add
end

# Set up cache flush agents
aem_replicator 'flush_cache' do
  local_user node[:aem][:publish][:admin_user]
  local_password lazy { node[:aem][:publish][:admin_password] }
  local_port node[:aem][:publish][:port]
  remote_hosts node[:aem][:publish][:cache_hosts]
  dynamic_cluster node[:aem][:publish][:find_cache_hosts_dynamically]
  cluster_name node[:aem][:cluster_name]
  cluster_role node[:aem][:dispatcher][:cluster_role]
  aem_version node[:aem][:version]
  type :flush
  action :add
end
