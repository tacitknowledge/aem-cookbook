#
# Cookbook Name:: aem
# Resource:: replicator
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

attribute :name, kind_of: String, name_attribute: true
attribute :local_user, kind_of: String, required: true
attribute :local_password, kind_of: String, required: true
attribute :local_port, kind_of: String, required: true
attribute :remote_hosts, kind_of: Array, default: []
attribute :dynamic_cluster, kind_of: [TrueClass, FalseClass], default: false
attribute :cluster_name, kind_of: String, default: nil
attribute :cluster_role, kind_of: String, default: nil
attribute :type, kind_of: Symbol, default: nil
attribute :server, kind_of: String, default: nil
attribute :aem_version, kind_of: String, default: nil
