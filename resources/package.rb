#
# Cookbook Name:: aem
# Resource:: package
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

# This resource manages AEM packages

actions :upload, :install, :activate, :uninstall, :delete

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :aem_instance, kind_of: String, required: true
attribute :pkg_mgr_url, kind_of: String, default: nil
attribute :package_url, kind_of: String, default: nil
attribute :version, kind_of: String, default: nil
attribute :file_extension, kind_of: String, default: '.zip'
attribute :update, kind_of: [TrueClass, FalseClass], default: false
attribute :user, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :port, kind_of: String, required: true
attribute :group_id, kind_of: String, default: nil
attribute :recursive, kind_of: [TrueClass, FalseClass], default: false
attribute :properties_file, kind_of: String, default: nil
attribute :version_pattern, kind_of: String, default: nil
