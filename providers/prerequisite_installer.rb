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
  # Use fallback attributes if property isn't passed
  base_dir = new_resource.base_dir || node[:aem][:base_dir]
  install_pkgs_on_start = new_resource.install_pkgs_on_start || node[:aem][:install_pkgs_on_start]
  package_store_url = new_resource.package_store_url || node[:aem][:package_store_url]

	install_dir = base_dir + '/install'

  directory install_dir do
    owner 'crx'
    group 'crx'
    mode '0755'
    action :create
  end

  install_pkgs_on_start.each_with_index do |file, index|
    # prepending index, since aem installs packages in alphabet order
    file_name = index.to_s + '_' + ::File.basename(file)

    # remote_file "#{install_dir}/#{file_name}" do
    #   source "#{package_store_url}/#{file}"
    #   owner 'crx'
    #   group 'crx'
    #   mode '0644'
    #   action :create_if_missing
    # end

    unless ::File.exist?("#{install_dir}/#{file_name}")
      s3_file "#{install_dir}/#{file_name}" do
        remote_path "/#{file}"
        bucket "horizon.aem"
        s3_url node[:aem][:package_store_url]
        aws_access_key_id "AKIAJRFQ6HHOMBYQOI4Q"
        aws_secret_access_key "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"
        owner 'crx'
        group 'crx'
        mode "0755"
        action :create
      end
    else
      Chef::Log.error("File exists: '#{install_dir}/#{file_name}'!. Skipping download... ")
    end
  end
end
