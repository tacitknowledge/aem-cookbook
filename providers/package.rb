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

def set_vars
  # Set up vars with AEM package manager urls, etc.
  vars = {}
  vars[:recursive] = new_resource.recursive ? '\\&recursive=true' : ''
  vars[:file_name] = "#{new_resource.name}-#{new_resource.version}" \
                     "#{new_resource.file_extension}"
  vars[:download_url] = new_resource.package_url
  vars[:file_path] = "#{Chef::Config[:file_cache_path]}/#{vars[:file_name]}"
  vars[:user] = new_resource.user
  vars[:password] = new_resource.password
  vars[:port] = new_resource.port
  vars[:group_id] = new_resource.group_id
  vars[:upload_cmd] = "curl -s -S -u #{vars[:user]}:#{vars[:password]} -F" \
                      " package=@#{vars[:file_path]} http://localhost:" \
                      "#{vars[:port]}/crx/packmgr/service/.json?cmd=upload"
  vars[:delete_cmd] = "curl -s -S -u #{vars[:user]}:#{vars[:password]} -X" \
                      " POST http://localhost:#{vars[:port]}/crx/packmgr/" \
                      "service/.json/etc/packages/#{vars[:group_id]}/" \
                      "#{vars[:file_name]}?cmd=delete"
  vars[:install_cmd] = "curl -s -S -u #{vars[:user]}:#{vars[:password]} -X" \
                       " POST http://localhost:#{vars[:port]}/crx/packmgr/" \
                       "service/.json/etc/packages/#{vars[:group_id]}/" \
                       "#{vars[:file_name]}?cmd=install#{vars[:recursive]}"
  vars[:activate_cmd] = "curl -s -S -u #{vars[:user]}:#{vars[:password]} -X" \
                       " POST http://localhost:#{vars[:port]}/crx/packmgr/" \
                       "service/.json/etc/packages/#{vars[:group_id]}/" \
                       "#{vars[:file_name]}?cmd=replicate"
  vars[:uninstall_cmd] = "curl -s -S -u #{vars[:user]}:#{vars[:password]} -X" \
                       " POST http://localhost:#{vars[:port]}/crx/packmgr/" \
                       "service/.json/etc/packages/#{vars[:group_id]}/" \
                       "#{vars[:file_name]}?cmd=uninstall"

  vars
end

def get_package_version(zip_file_path, properties_file_path, pattern)
  # The package versions inside the zip file may have no relationship to the
  # version on the file.
  cmd = "unzip -p #{zip_file_path} #{properties_file_path}"
  get_version = Mixlib::ShellOut.new(cmd)
  get_version.run_command
  get_version.error!
  puts "PROPERTIES FILE:\n #{get_version.stdout}"
  puts "PATTERN: #{pattern}"
  match = pattern.match(get_version.stdout)
  fail "Failed to find AEM package version in #{zip_file_path}." unless match
  puts "Found AEM package version: #{match[1]}"
  # return the captured text
  match[1]
end

action :upload do
  # I only wish there was a way to get AEM to tell you what packages are already
  #  installed.  The Hack follows.

  vars = set_vars
  unless ::File.exist?(vars[:file_path]) && !new_resource.update
    r = remote_file vars[:file_path] do
      source vars[:download_url]
      mode 0755
      action :nothing
    end
    r.run_action(:create)

    # If we're going to do the upload, make sure the package is not already there
    delete = Mixlib::ShellOut.new(vars[:delete_cmd])
    upload = Mixlib::ShellOut.new(vars[:upload_cmd])
    log "Deleting AEM package with command: #{vars[:delete_cmd]}"
    delete.run_command
    delete.error!
    log delete.stdout
    log "Uploading AEM package with command: #{vars[:upload_cmd]}"
    upload.run_command
    upload.error!
    log upload.stdout

  end
end

action :delete do
  vars = set_vars
  delete = Mixlib::ShellOut.new(vars[:delete_cmd])
  log "Deleting AEM package with command: #{vars[:delete_cmd]}"
  delete.run_command
  delete.error!
  log delete.stdout
  file vars[:file_path] do
    action :delete
  end
end

action :install do
  vars = set_vars

  # If we're using something like "latest", the version of the packages won't
  # match, so we need to get the real version.
  if new_resource.properties_file && new_resource.version_pattern
    pat = Regexp.new(new_resource.version_pattern)
    package_version = get_package_version(vars[:file_path],
                                          new_resource.properties_file, pat)
    vars[:install_cmd].sub!(new_resource.version, package_version)
    puts "NEW VERSION: #{package_version}"
  end

  puts "INSTALL COMMAND: #{vars[:install_cmd]}"
  install = Mixlib::ShellOut.new(vars[:install_cmd])

  # We need to figure out what version is currently installed, if any.
  # AEM won't tell us this, so we leave ourselves breadcrumbs.
  version_dir = "#{node[:aem][new_resource.aem_instance][:default_context]}/" \
                 'packages'
  version_file = "#{version_dir}/#{new_resource.name}"
  current_version = nil
  if ::File.exist?(version_file)
    current_version = ::File.readlines(version_file).last.chomp
  end
  # Need to uninstall the current version - AEM just overlays a new install
  if (current_version != new_resource.version) || new_resource.update
    old = "#{new_resource.name}-#{current_version}#{new_resource.file_extension}"
    uninstall_cmd = vars[:uninstall_cmd].sub(vars[:file_name], old)
    uninstall = Mixlib::ShellOut.new(uninstall_cmd)
    log "Uninstalling AEM package with command: #{uninstall_cmd}"
    uninstall.run_command
    uninstall.error!
    log uninstall.stdout
    log "Installing AEM package with command: #{vars[:install_cmd]}"
    install.run_command
    install.error!
    log install.stdout
  end
  # Now to leave the breadcrumb
  params = { version: new_resource.version }
  directory version_dir do
    owner 'root'
    group 'root'
    mode '0755'
  end
  template version_file do
    owner 'root'
    group 'root'
    mode '0644'
    source 'aem_pkg_version.erb'
    variables(params: params)
  end
end

action :activate do
  vars = set_vars
  if new_resource.properties_file && new_resource.version_pattern
    pat = Regexp.new(new_resource.version_pattern)
    package_version = get_package_version(vars[:file_path],
                                          new_resource.properties_file, pat)
    vars[:activate_cmd].sub!(new_resource.version, package_version)
  end
  activate = Mixlib::ShellOut.new(vars[:activate_cmd])
  log "Activating AEM package with command: #{vars[:activate_cmd]}"
  activate.run_command
  activate.error!
  log activate.stdout
end

action :uninstall do
  vars = set_vars
  uninstall = Mixlib::ShellOut.new(vars[:uninstall_cmd])
  log "Uninstalling AEM package with command: #{vars[:uninstall_cmd]}"
  uninstall.run_command
  uninstall.error!
  log uninstall.stdout
end
