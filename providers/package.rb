#
# Cookbook Name:: aem
# Provider:: package
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

# This provider manages AEM packages. It is not intended for production use,
# though it can be useful for standing-up developer environments.  If you
# really want to use this for production, you should add some real error
# checking on the output of the curl commands.
require 'time'
require 'json'
require 'rest_client'

# Queries AEM. Returns an array of all packages matching the package_name
# Each element within the array is a Hash representing an individual package.
# Example package Hash below:
# [{
#   "group"=>"com.xxx.aem",
#   "name"=>"aem-deployment",
#   "version"=>"1.2.3",
#   "downloadname"=>"aem-deployment-1.2.2.zip",
#   "size"=>"9166080",
#   "created"=>"Thu, 12 Feb 2015 16:41:49 +0000",
#   "createdby"=>"admin",
#   "lastmodified"=>nil,
#   "lastmodifiedby"=>"null",
#   "lastunpacked"=>"Fri, 13 Feb 2015 21:51:13 +0000",
#   "lastunpackedby"=>"admin"
# }]
def get_current_packages package_name
  require 'nokogiri'
  require 'open-uri'
  require 'active_support/core_ext/hash/conversions'
  uri = "http://#{new_resource.aem_host}:#{new_resource.port}/crx/packmgr/service.jsp?cmd=ls"
  page = Nokogiri::HTML(open( uri, :http_basic_authentication => [new_resource.user, new_resource.password] ))
  response_code = page.xpath("//response/status/@code")
  raise "Invalid response (#{response_code}) while listing packages from #{uri}." unless response_code.to_s == "200"
  @packages = page.xpath("//response/data/packages/package[name='#{package_name}']")
  @packages.map {|p| Hash.from_xml(p.to_s)['package']}
end

# If we're using something like "latest", the version within the package (number) may not
# match the version passed to the resource (latest), so we need to get the real (number) version.
def get_package_version
  if new_resource.properties_file && new_resource.version_pattern
    download_package
    pattern = Regexp.new(new_resource.version_pattern)
    cmd = "unzip -p #{new_resource.file_path} #{new_resource.properties_file}"
    get_version = Mixlib::ShellOut.new(cmd)
    get_version.run_command
    get_version.error!
    match = pattern.match(get_version.stdout)
    raise "Failed to find AEM package version in #{new_resource.file_path}." unless match
    log "#{Time.now.iso8601(3)}: Found AEM version '#{match[1]}' in package '#{new_resource.file_path}'" do
      level :debug
    end
    return match[1]
  end
  new_resource.version
end

def aem_req(overrides={})
  require 'uri'
  options = {
    :method => :post,
    :user => new_resource.user,
    :password => new_resource.password,
    :timeout => new_resource.timeout
  }
  options.merge!(overrides)
  # The URI Path is passed to this method as the 'url' option. We update the url with the protocol, hostname, and port.
  options[:url] = URI.encode("http://#{new_resource.aem_host}:#{new_resource.port}#{options[:url]}")
  log "Modifying package: #{options[:url]}\n"
  response = JSON.parse(RestClient::Request.execute(options))
  log "Success: #{response['success']}, Message: #{response['msg']} for #{options[:url]}}\n"
  raise "Unsuccessful response from AEM Server: #{response}" unless response['success']
  response
end

def download_package
  # Only create new resource if needed (CHEF-3694)
  begin
    # Try to lookup the remote file resource
    run_context.resource_collection.find(:remote_file => new_resource.file_path)
  rescue Chef::Exceptions::ResourceNotFound
    # Resource doesn't exist, create now
    r = remote_file new_resource.file_path do
      source new_resource.package_url
      mode 0755
      checksum new_resource.checksum
    end
    r.run_action(:create)
  end
end

def delete_package(file_name)
  aem_req({:url => "/crx/packmgr/service/.json/etc/packages/#{new_resource.group_id}/#{file_name}?cmd=delete"})
end

def upload_package(file_path)
  download_package
  aem_req({:url => '/crx/packmgr/service/.json?cmd=upload',
           :content_type => 'application/octet-stream',
           :payload => {:multipart => true, :package => ::File.new(file_path, 'rb'), :filename => ::File.basename(file_path)}
          })
end

def install_package(file_name)
  recursive = new_resource.recursive ? '&recursive=true' : ''
  aem_req({:url => "/crx/packmgr/service/.json/etc/packages/#{new_resource.group_id}/#{file_name}?cmd=install#{recursive}"})
end

def activate_package(file_name)
  aem_req({:url => "/crx/packmgr/service/.json/etc/packages/#{new_resource.group_id}/#{file_name}?cmd=replicate"})
end

def uninstall_package(file_name)
  aem_req({:url => "/crx/packmgr/service/.json/etc/packages/#{new_resource.group_id}/#{file_name}?cmd=uninstall"})
end

action :upload do
  package_version = get_package_version
  @uploaded_packages = get_current_packages(new_resource.name)
  # Uninstall and delete all existing packages that do not match current package version
  @uploaded_packages.each do |uploaded_package|
    unless uploaded_package['version'] == package_version
      uninstall_package(uploaded_package['downloadname']) unless uploaded_package['lastunpacked'] == nil
      delete_package(uploaded_package['downloadname'])
    end
  end
  # Upload this package unless it's already uploaded
  upload_package(new_resource.file_path) unless @uploaded_packages.any? { |uploaded_package| uploaded_package['version'] == package_version }
end

action :delete do
  delete_package(new_resource.file_name)
  file new_resource.file_path do
    action :delete
  end
end

action :install do
  package_version = get_package_version
  @uploaded_packages = get_current_packages(new_resource.name)
  # Uninstall and delete all existing packages that do not match current package version
  @uploaded_packages.each do |uploaded_package|
     unless uploaded_package['version'] == package_version
       uninstall_package(uploaded_package['downloadname']) unless uploaded_package['lastunpacked'] == nil
       delete_package(uploaded_package['downloadname'])
     end
  end
  # Upload the package unless it is already uploaded
  upload_package(new_resource.file_path) unless @uploaded_packages.any? { |uploaded_package| uploaded_package['version'] == package_version }
  # Install package unless it is already installed
  install_package(new_resource.file_name) unless @uploaded_packages.any? { |uploaded_package| uploaded_package['version'] == package_version && uploaded_package['lastunpacked'] != nil }
end

action :activate do
  activate_package(new_resource.file_name)
end

action :uninstall do
  uninstall_package(new_resource.file_name)
end
