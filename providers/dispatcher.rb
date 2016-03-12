#
# Cookbook Name:: aem
# Provider:: dispatcher
#
# Copyright 2014, Tacit Knowledge, Inc.
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
  dispatcher_mod_name = new_resource.dispatcher_mod_name
  package_install = new_resource.package_install
  dispatcher_uri = new_resource.dispatcher_uri
  dispatcher_checksum = new_resource.dispatcher_checksum
  dispatcher_version = new_resource.dispatcher_version
  dispatcher_file_cookbook = new_resource.dispatcher_file_cookbook
  webserver_type = new_resource.webserver_type
  apache_libexecdir = new_resource.apache_libexecdir

  if package_install
    dispatcher_pkg = "aem-dispatcher-#{webserver_type}"
    package dispatcher_pkg do
      version dispatcher_version
    end
  else
    dispatcher_file_path = "dispatcher-#{webserver_type}-#{dispatcher_version}.so"
    local_file_path = "#{apache_libexecdir}/#{dispatcher_file_path}"
    service_name = 'service[apache2]'

    unless dispatcher_uri.nil?
      require 'uri'
      uri = URI.parse(dispatcher_uri)
      filename = ::File.basename(uri.path)

      case ::File.extname(filename)
      when '.so'
        remote_file local_file_path do
          source dispatcher_uri
          checksum dispatcher_checksum
          mode 0644
          owner 'root'
          group 'root'
          action :create
          notifies :restart, service_name
        end
      else
        # extract out the module.so
        ark filename do
          url dispatcher_uri
          checksum dispatcher_checksum
          creates "modules/dispatcher-#{webserver_type}-*#{dispatcher_version}.so"
          path apache_libexecdir
          action :cherry_pick
        end
      end

    else
      cookbook_file local_file_path do
        source "#{dispatcher_file_path}"
        mode 0644
        owner 'root'
        group 'root'
        cookbook dispatcher_file_cookbook
        action :create
        notifies :restart, service_name
      end
    end

    link "#{apache_libexecdir}/mod_dispatcher.so" do
      to local_file_path
      notifies :restart, service_name
    end
  end
end
