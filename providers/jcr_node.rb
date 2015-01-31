#
# Cookbook Name:: aem
# Provider:: jcr_node
#
# Copyright 2015, Tacit Knowledge, Inc.
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

# This provider manages an AEM JCR node

def curl(url, user, password) do
  c = Curl::Easy.new(url)
  c.http_auth_types = :basic
  c.username = user
  c.password = password
  c.perform
  c
end

def check_node(url, user, password) do
  c = curl(url, user, password)
  case c.response_code
  when 200
    c.body_str
  when 404
    false
  else
    raise "Unable to read JCR node at #{url}. response: #{c.body_str}"
  end
end

def make_url(new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/#{new_resource.path}"
end

action :create do
  url = make_url(new_resource)
  unless check_node(url, new_resource.user, new_resource.password) == new_resource.content

  end
end

action :delete do
end
