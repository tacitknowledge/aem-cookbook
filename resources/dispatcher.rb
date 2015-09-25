#
# Cookbook Name:: aem
# Resource:: dispatcher
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

actions :install

attribute :dispatcher_mod_name, kind_of: String, name_attribute: true
attribute :package_install, kind_of: [TrueClass, FalseClass], default: false
attribute :dispatcher_uri, kind_of: String, default: nil
attribute :dispatcher_checksum, kind_of: String, default: nil
attribute :dispatcher_version, kind_of: String, default: nil
attribute :dispatcher_file_cookbook, kind_of: String, default: nil
attribute :webserver_type, kind_of: String, default: nil
attribute :apache_libexecdir, kind_of: String, default: nil
