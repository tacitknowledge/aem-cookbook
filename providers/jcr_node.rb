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

def http_get(url, user, password)
  res = RestClient::Resource.new(url, user, password)
  res.get
end

def http_post(url, user, password, fields)
  res = RestClient::Resource.new(url, user, password)
  res.post(fields)
end

def check_node(url, user, password, name)
  url = "#{url}/#{name}"
  res = http_get(url, user, password)
  case res.code
  when 200, 201
    res.to_str
  when 404
    false
  else
    fail "Unable to read JCR node at #{url}. response_code: #{res.code} response: #{res.to_str}"
  end
end

def make_url(new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/#{new_resource.path}"
end

action :create do
  url = make_url(new_resource)
  # How to create the node depends on the type.  I'm only supporting type 'file' right now.
  case new_resource.type
  when 'file'
    unless check_node(url, new_resource.user, new_resource.password, new_resource.name) == new_resource.contents
      # EH This doesn't work!! Fields need to be in right format, need to figure out what AEM api expects
      fields = {metadata: new_resource.name, :content => new_resource.contents }

      #[
      #  Curl::PostField.file(new_resource.name, new_resource.contents),
      #  Curl::PostField.content("#{new_resource.name}@TypeHint", 'Binary')
      #]


      res = http_post(url, new_resource.user, new_resource.password, fields)
      if res.code == 200 || res.code == 201
        new_resource.updated_by_last_action(true)
        Chef::Log.debug("New jcr_node was created at #{new_resource.path}")
      else
        fail "JCR Node Creation failed.  HTTP code: #{res.code}"
      end
    end
  else
    fail "Node type '#{new_resource.type}' is unsupported for creation.  If you need this type, please file an issue, or better yet, a pull request."
  end
end

action :delete do
  url = make_url(new_resource)
  if check_node(url, new_resource.user, new_resource.password, new_resource.name)
    # If the node exists, delete it
    # EH might not have to be multipart
    fields = {operation: 'delete', multipart: true}
    res = http_post(url, new_resource.user, new_resource.password, fields)
    if res.code == 200 || res.code == 201
      new_resource.updated_by_last_action(true)
    else
      fail "JCR Node Deletion failed.  HTTP code: #{res.code}"
    end
  end
end
