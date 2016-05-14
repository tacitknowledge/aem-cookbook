#
# Cookbook Name:: aem
# Recipe:: author
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
  aem_jar_installer 'author' do
    download_url node[:aem][:download_url]
    default_context node[:aem][:author][:default_context]
    port node[:aem][:author][:port]
    action :install
  end
end

unless node[:aem][:license_customer_name].nil? && node[:aem][:license_download_id].nil?
  template "#{node[:aem][:author][:default_context]}/license.properties" do
    source 'license.properties.erb'
    sensitive true
    mode 0644
  end
end

unless node[:aem][:license_url].nil?
  remote_file "#{node[:aem][:author][:default_context]}/license.properties" do
    source "#{node[:aem][:license_url]}"
    sensitive true
    mode 0644
  end
end

if node[:aem][:version].to_f > 5.4
  node.set[:aem][:author][:runnable_jar] = "aem-author-p#{node[:aem][:author][:port]}.jar"
end

aem_init 'aem-author' do
  service_name 'aem-author'
  default_context node[:aem][:author][:default_context]
  runnable_jar node[:aem][:author][:runnable_jar]
  base_dir node[:aem][:author][:base_dir]
  jvm_opts node[:aem][:author][:jvm_opts]
  jar_opts node[:aem][:author][:jar_opts]
  action :add
end

service 'aem-author' do
  # init script returns 0 for status no matter what
  status_command 'service aem-author status | grep running'
  supports status: true, stop: true, start: true, restart: true
  action [:enable, :start]
end

if node[:aem][:version].to_f > 5.4
  node[:aem][:author][:validation_urls].each do |url|
    aem_url_watcher url do
      validation_url url
      status_command 'service aem-author status | grep running'
      max_attempts node[:aem][:author][:startup][:max_attempts]
      wait_between_attempts node[:aem][:author][:startup][:wait_between_attempts]
      user node[:aem][:author][:admin_user]
      password node[:aem][:author][:admin_password]
      action :wait
    end
  end
else
  aem_port_watcher '4502' do
    status_command 'service aem-author status | grep running'
    action :wait
  end
end

unless node[:aem][:author][:new_admin_password].nil?
  # Change admin password
  aem_user node[:aem][:author][:admin_user] do
    password node[:aem][:author][:new_admin_password]
    admin_user node[:aem][:author][:admin_user]
    admin_password node[:aem][:author][:admin_password]
    port node[:aem][:author][:port]
    aem_version node[:aem][:version]
    action :set_password
  end

  node.set[:aem][:author][:admin_password] = node[:aem][:author][:new_admin_password]
  node.set[:aem][:author][:new_admin_password] = nil
end

# delete the privileged users from geometrixx, if they're still there.
node[:aem][:geometrixx_priv_users].each do |user|
  aem_user user do
    admin_user node[:aem][:author][:admin_user]
    admin_password lazy { node[:aem][:author][:admin_password] }
    port node[:aem][:author][:port]
    aem_version node[:aem][:version]
    path '/home/users/geometrixx'
    action :remove
  end
end

aem_ldap 'author' do
  options node[:aem][:author][:ldap][:options]
  action node[:aem][:author][:ldap][:enabled] ? :enable : :disable
end

if node[:aem][:version].to_f < 5.5
  web_inf_dir = "#{node[:aem][:author][:base_dir]}/server/runtime/0/_crx/WEB-INF"
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
    notifies :restart, 'service[aem-author]'
  end
end

# If we're using the aem_package provider to deploy, do it now
node[:aem][:author][:deploy_pkgs].each do |pkg|
  aem_package pkg[:name] do
    version pkg[:version]
    aem_instance 'author'
    package_url pkg[:url]
    update pkg[:update]
    user node[:aem][:author][:admin_user]
    password lazy { node[:aem][:author][:admin_password] }
    port node[:aem][:author][:port]
    group_id pkg[:group_id]
    recursive pkg[:recursive]
    properties_file pkg[:properties_file]
    version_pattern pkg[:version_pattern]
    action pkg[:action]
  end
end

# Remove author agents that aren't listed
aem_replicator 'delete_extra_replication_agents' do
  local_user node[:aem][:author][:admin_user]
  local_password lazy { node[:aem][:author][:admin_password] }
  local_port node[:aem][:author][:port]
  remote_hosts node[:aem][:author][:replication_hosts]
  dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
  cluster_name node[:aem][:cluster_name]
  cluster_role node[:aem][:publish][:cluster_role]
  aem_version node[:aem][:version]
  type :agent
  action :remove
end

# Set up author agents
aem_replicator 'create_replication_agents_for_publish_servers' do
  local_user node[:aem][:author][:admin_user]
  local_password lazy { node[:aem][:author][:admin_password] }
  local_port node[:aem][:author][:port]
  remote_hosts node[:aem][:author][:replication_hosts]
  dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
  cluster_name node[:aem][:cluster_name]
  cluster_role node[:aem][:publish][:cluster_role]
  aem_version node[:aem][:version]
  type :agent
  action :add
end

# Set up replication agents
aem_replicator 'replicate_to_publish_servers' do
  local_user node[:aem][:author][:admin_user]
  local_password lazy { node[:aem][:author][:admin_password] }
  local_port node[:aem][:author][:port]
  remote_hosts node[:aem][:author][:replication_hosts]
  dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
  cluster_name node[:aem][:cluster_name]
  cluster_role node[:aem][:publish][:cluster_role]
  aem_version node[:aem][:version]
  type :publish
  action :add
end
