#
# Cookbook Name:: aem
# Resource:: farm
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

actions :add, :remove

attribute :farm_name, kind_of: String, name_attribute: true
attribute :client_headers, kind_of: Array, default: nil
attribute :virtual_hosts, kind_of: Array, default: nil
attribute :renders, kind_of: Array, default: nil
attribute :filter_rules, kind_of: Hash, default: nil
attribute :cache_root, kind_of: String, default: nil
attribute :farm_dir, kind_of: String, default: nil
attribute :cache_rules, kind_of: Hash, default: nil
attribute :invalidation_rules, kind_of: Hash, default: nil
attribute :allowed_clients, kind_of: Hash, default: nil
attribute :ignore_url_params, kind_of: Hash, default: nil
attribute :statistics, kind_of: Array, default: nil
attribute :cache_opts, kind_of: Array, default: nil
attribute :session_mgmt, kind_of: Hash, default: nil
attribute :enable_session_mgmt, kind_of: [TrueClass, FalseClass], default: false
attribute :dynamic_cluster, kind_of: [TrueClass, FalseClass], default: false
attribute :cluster_name, kind_of: String, default: nil
attribute :cluster_role, kind_of: String, default: nil
attribute :cluster_type, kind_of: String, default: nil
attribute :render_timeout, kind_of: Integer, default: 0
attribute :farm_template_cookbook, kind_of: String, default: 'aem'
attribute :farm_template_source, kind_of: String, default: 'farm.any.erb'
