actions :install

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :package_store_url, kind_of: String, default: nil
attribute :base_dir, kind_of: String, default: nil
attribute :install_pkgs_on_start, kind_of: Array, default: nil
