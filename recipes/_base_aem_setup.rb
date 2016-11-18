#
# Cookbook Name:: aem
# Recipe:: _base_aem_setup
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

# Platform specific package names
case node['platform']
when 'debian', 'ubuntu'
  curl_package = 'libcurl4-openssl-dev'
when 'redhat', 'centos', 'fedora'
  curl_package = 'libcurl-devel'
end

# We need these for the jcr_node provider
package curl_package do
  action :nothing
end.run_action(:install)

package 'gcc' do
  action :nothing
end.run_action(:install)

chef_gem 'curb' do
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
  action :nothing
end.run_action(:install)

require 'curb'

unless node['aem']['license_url'] || node['aem']['license_customer_name'] && node['aem']['license_download_id']
  Chef::Application.fatal! 'At lest one of aem.license_url or aem.license_customer_name && aem.license_download_id attribute should not be nil. Please populate that attribute.'
end

unless node['aem']['download_url']
  Chef::Application.fatal! 'aem.download attribute cannot be nil. Please populate that attribute.'
end

# See if we can get this value early enough from AEM itself so we don't have to ask for it.
unless node['aem']['version']
  Chef::Application.fatal! 'aem.version attribute cannot be nil. Please populate that attribute.'
end

include_recipe 'java'
package 'unzip'

if node[:aem][:use_yum]
  package 'aem' do
    version node[:aem][:version]
    action :install
  end
else
  user 'crx' do
    comment 'crx/aem role user'
    system true
    shell '/bin/bash'
    home '/home/crx'
    supports manage_home: true
    action :create
  end
end

directory '/home/crx/.ssh' do
  owner 'crx'
  group 'crx'
  mode 0700
end
