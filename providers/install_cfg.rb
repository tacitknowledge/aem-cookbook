#
# Cookbook Name:: aem
# Provider:: install_cfg
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

# This provider creates crx-quickststart/install configuration files

action :add do
  service_name = new_resource.service_name
  base_dir = new_resource.base_dir
  configs = new_resource.configs

  directory "#{base_dir}/install" do
    owner "crx"
    mode "0755"
    recursive true
    action :create
  end

  # create each file..
  configs.each do |cfg|
    name = cfg["name"]
    vars = {}
    vars["settings"] = cfg["settings"]

    template "#{base_dir}/install/#{name}" do
      cookbook "aem"
      source "install.cfg.erb"
      mode "0755"
      variables(vars)
      action :create_if_missing
    end
  end

end
