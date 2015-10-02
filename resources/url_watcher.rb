#
# Cookbook Name:: services
# Resource:: url_watcher
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

actions :wait

attribute :name, kind_of: String, name_attribute: true
attribute :validation_url, kind_of: String, default: nil, required: true
attribute :status_command, kind_of: String, default: nil, required: true
attribute :max_attempts, kind_of: Integer, default: nil, required: true
attribute :wait_between_attempts, kind_of: Integer, default: nil, required: true
attribute :user, kind_of: String, default: nil
attribute :password, kind_of: String, default: nil
attribute :match_string, kind_of: String, default: nil
