#
# Cookbook Name:: aem
# Resource:: bundle
#
# This resource manages AEM bundles

actions :install_bundle, :stop_bundle, :start_bundle, :delete_bundle, :uninstall_bundle

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :aem_instance, kind_of: String, required: true
attribute :bundle_mgr_url, kind_of: String, default: nil
attribute :bundle_url, kind_of: String, default: nil
attribute :version, kind_of: String, default: nil
attribute :file_extension, kind_of: String, default: '.jar'
attribute :user, kind_of: String, required: true
attribute :password, kind_of: String, required: true
attribute :port, kind_of: String, required: true