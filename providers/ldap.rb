#
# Cookbook Name:: aem
# Provider:: ldap
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

# This provider enables or disables ldap auth for an AEM instance

action :enable do
  vars = {}
  instance_name = new_resource.instance_name
  base_dir = node[:aem][instance_name][:base_dir]
  user = node[:aem][:aem_options]['RUNAS_USER']

  # take value passed to provider, or node attribute
  vars[:options] = new_resource.send(:options) ||
                   node[:aem][instance_name][:ldap][:options]

  directory "#{base_dir}/conf" do
    owner user
    group user
    mode '0755'
    action :create
    recursive true
  end

  template "#{base_dir}/conf/ldap_login.conf" do
    cookbook 'aem'
    source 'ldap_login.conf.erb'
    mode '0644'
    variables(vars)
    notifies :restart, resources(service: "aem-#{instance_name}")
  end

  # add the JVM option to use ldap, it will get added to startup script.
  opt = '-Djava.security.auth.login.config=crx-quickstart/conf/ldap_login.conf'
  node.default[:aem][instance_name][:jvm_opts][opt] = true
end

action :disable do
  instance_name = new_resource.instance_name
  file "#{node[:aem][instance_name][:base_dir]}/conf/ldap_login.conf" do
    action :delete
  end
  opt = '-Djava.security.auth.login.config=crx-quickstart/conf/ldap_login.conf'

  node.default[:aem][instance_name][:jvm_opts].delete(opt)
end
