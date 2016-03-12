#
# Cookbook Name:: aem
# Resource:: website
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

# This resource will add or remove an apache virtual host containing locations
# that will be served by dispatcher

actions :add, :remove

attribute :site_name, kind_of: String, name_attribute: true
attribute :server_name, kind_of: String, default: nil
attribute :server_aliases, kind_of: Array, default: nil
attribute :aem_locations, kind_of: Array, default: nil
attribute :cache_root, kind_of: String, default: nil
attribute :enabled, kind_of: String, default: nil
attribute :rewrites, kind_of: Array, default: nil
attribute :listen_port, kind_of: String, default: nil
attribute :ssl_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :ssl_cert_file, kind_of: String, default: nil
attribute :ssl_key_file, kind_of: String, default: nil
attribute :expire_dirs, kind_of: Array, default: nil
attribute :enable_etag, kind_of: [TrueClass, FalseClass], default: false
attribute :enable_ie_header, kind_of: [TrueClass, FalseClass], default: false
attribute :template_cookbook, kind_of: String, default: 'aem'
attribute :template_name, kind_of: String, default: 'aem_dispatcher.conf.erb'
attribute :deflate_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :local_vars, kind_of: Hash, default: nil
attribute :header, kind_of: Array, default: nil
