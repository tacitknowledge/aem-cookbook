#
# Cookbook Name:: aem
# Resource:: install_cfg
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

# This resource creates crx-quickstart/install configuration files

actions :add

attribute :service_name, :kind_of => String, :name_attribute => true, :required => true
attribute :base_dir, :kind_of => String, :default => nil
attribute :configs, :kind_of => Array, :default => nil
