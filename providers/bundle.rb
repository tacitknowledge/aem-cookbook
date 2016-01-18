# This provider manages AEM bundles. It is not intended for production use,
# though it can be useful for standing-up developer environments.  If you
# really want to use this for production, you should add some real error
# checking on the output of the curl commands.

def set_vars
  # Set up vars
  vars = {}
  vars[:bundle_name] = "#{new_resource.name}"
  vars[:file_name] = "#{new_resource.name}-#{new_resource.version}" \
                     "#{new_resource.file_extension}"
  vars[:download_url] = new_resource.bundle_url
  vars[:file_path] = "#{Chef::Config[:file_cache_path]}/#{vars[:file_name]}"
  vars[:user] = new_resource.user
  vars[:password] = new_resource.password
  vars[:port] = new_resource.port

  vars[:install_cmd] = "curl -u #{vars[:user]}:#{vars[:password]} " \
                          "-F action=install -F bundlestartlevel=20 " \
                          "-F bundlefile=@#{vars[:file_path]} http://localhost:#{vars[:port]}/system/console/bundles"
  vars[:stop_cmd] = "curl -u #{vars[:user]}:#{vars[:password]} " \
                          "-F action=stop " \
                          "http://localhost:#{vars[:port]}/system/console/bundles/#{vars[:bundle_name]}"
  vars[:start_cmd] = "curl -u #{vars[:user]}:#{vars[:password]} " \
                          "-F action=start " \
                          "http://localhost:#{vars[:port]}/system/console/bundles/#{vars[:bundle_name]}"
  # Delete command removes default Felix configuration so as to make sure that CRX configuration
  # from /apps/config.runmode are correctly picked up
  vars[:delete_cmd] = "curl -u #{vars[:user]}:#{vars[:password]} " \
                          "-F action=delete " \
                          "http://localhost:#{vars[:port]}/system/console/bundles/#{vars[:bundle_name]}"
  # Uninstall command removes the bundle
  vars[:uninstall_cmd] = "curl -u #{vars[:user]}:#{vars[:password]} " \
                          "-daction=uninstall " \
                          "http://localhost:#{vars[:port]}/system/console/bundles/#{vars[:bundle_name]}"
  vars
end


action :install_bundle do
  vars = set_vars
  r = remote_file vars[:file_path] do
    source vars[:download_url]
    mode 0755
    action :nothing
  end
  r.run_action(:create)

  install = Mixlib::ShellOut.new(vars[:install_cmd])
  log "Installing AEM Felix bundle with command: #{vars[:install_cmd]}"
  install.run_command
  install.error!
  log install.stdout
end

action :stop_bundle do
  vars = set_vars
  stop = Mixlib::ShellOut.new(vars[:stop_cmd])
  log "Stopping AEM bundle with command: #{vars[:stop_cmd]}"
  stop.run_command
  stop.error!
  log stop.stdout
end

action :start_bundle do
  vars = set_vars
  start = Mixlib::ShellOut.new(vars[:start_cmd])
  log "Starting AEM bundle with command: #{vars[:start_cmd]}"
  start.run_command
  start.error!
  log start.stdout
end

action :delete_bundle do
  vars = set_vars
  delete = Mixlib::ShellOut.new(vars[:delete_cmd])
  log "Deleting AEM bundle with command: #{vars[:delete_cmd]}"
  delete.run_command
  delete.error!
  log delete.stdout
  file vars[:file_path] do
    action :delete
  end
end

action :uninstall_bundle do
  vars = set_vars
  uninstall = Mixlib::ShellOut.new(vars[:uninstall_cmd])
  log "Uninstalling AEM bundle with command: #{vars[:uninstall_cmd]}"
  uninstall.run_command
  uninstall.error!
  log uninstall.stdout
  file vars[:file_path] do
    action :uninstall
  end
end