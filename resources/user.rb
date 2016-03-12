#
# Cookbook Name:: aem
# Resource:: password
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

# This resource sets a users password for AEM

actions :add, :remove, :set_password

attribute :user, kind_of: String, name_attribute: true
attribute :password, kind_of: String, default: nil
attribute :admin_user, kind_of: String, default: nil
attribute :admin_password, kind_of: String, default: nil
attribute :port, kind_of: String, default: nil
attribute :aem_version, kind_of: String, default: node[:aem][:version]
attribute :path, kind_of: String, default: nil # the path to the user in AEM
attribute :group, kind_of: String, default: nil
