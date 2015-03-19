#
# Cookbook Name:: aem
# Attributes:: default
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
#

include_attribute "apache2"

default[:aem][:version] = nil
default[:aem][:jvm_opts] = {}
default[:aem][:jar_opts] = []
default[:aem][:enable_webdav] = false
default[:aem][:jar_name] = nil
default[:aem][:use_yum] = false
default[:aem][:download_url] = nil
default[:aem][:license_url] = nil
default[:aem][:base_dir] = "/opt/aem"
default[:aem][:cluster_name] = nil
default[:aem][:geometrixx_priv_users] = [
  'author', 'jdoe@geometrixx.info', 'aparker@geometrixx.info'
]
default[:aem][:aem_options] = {
  "JAVA_HOME" => "/usr/java/default",
  "RUNAS_USER" => "crx",
  "CQ_HEAP_MIN" => "128",
  "CQ_HEAP_MAX" => "384",
  "CQ_PERMGEN" => "128"
}
default[:aem][:commands] = {
  :replicators => {
    :publish => { :add => 'curl -u <%=local_user%>:<%=local_password%> -X POST http://localhost:<%=local_port%>/etc/replication/agents.<%=server%>/<%=aem_instance%><%=instance%>/_jcr_content -d jcr:title="<%=type%> Agent <%=instance%>" -d transportUri=http://<%=h[:ipaddress]%>:<%=h[:port]%>/bin/receive?sling:authRequestLogin=1 -d enabled=true -d transportUser=<%=h[:user]%> -d transportPassword=<%=h[:password]%> -d cq:template="/libs/cq/replication/templates/agent" -d retryDelay=60000 -d logLevel=info -d serializationType=durbo -d jcr:description="<%=type%> Agent <%=instance%>" -d sling:resourceType="cq/replication/components/agent"'},
    :flush => {:add => 'curl -u <%=local_user%>:<%=local_password%> -X POST http://localhost:<%=local_port%>/etc/replication/agents.<%=server%>/flush<%=instance%>/_jcr_content  -d transportUri=http://<%=h[:ipaddress]%>/dispatcher/invalidate.cache -d enabled=true -d transportUser=<%=h[:user]%> -d transportPassword=<%=h[:password]%> -d jcr:title=flush<%=instance%> -d jcr:description=flush<%=instance%> -d serializationType=flush -d cq:template=/libs/cq/replication/templates/agent -d sling:resourceType="cq/replication/components/agent" -d retryDelay=60000 -d logLevel=info -d triggerSpecific=true -d triggerReceive=true'},
    :flush_agent => {:add => 'curl -F "jcr:primaryType=cq:Page" -F "jcr:content=" -u <%=local_user%>:<%=local_password%> http://localhost:<%=local_port%>/etc/replication/agents.<%=server%>/<%=agent%><%=instance%>'},
    :agent => {:add => 'curl -F "jcr:primaryType=cq:Page" -F "jcr:content=" -u <%=local_user%>:<%=local_password%> http://localhost:<%=local_port%>/etc/replication/agents.<%=server%>/<%=agent%><%=instance%>',
               :remove => 'curl -u <%=local_user%>:<%=local_password%> -X DELETE http://localhost:<%=local_port%>/etc/replication/agents.<%=server%>/<%=h%>',
               :list => 'curl -u <%=local_user%>:<%=local_password%> http://localhost:<%=local_port%>/etc/replication.infinity.json'}
  },
  :password => {
    :aem54 => 'curl -f --data rep:password=<%= password %> --user <%= admin_user %>:<%= admin_password %> http://localhost:<%= port %><%= path %>/<%= user %>',
    :aem55 => 'curl -f --user <%= admin_user %>:<%= admin_password %> -F rep:password="<%= password %>" http://localhost:<%= port %><%= path %>/<%= user %>.rw.html',
    :aem60 => 'curl -u <%= admin_user %>:<%= admin_password %> -Fplain=<%= password %> -Fverify=<%= password %> -Fold=<%= admin_password %> -FPath=<%= path %>/<%= admin_user %> http://localhost:<%= port %>/crx/explorer/ui/setpassword.jsp'
  },
  :remove_user => {
    :aem55 => 'curl -u <%= admin_user %>:<%= admin_password %> -FdeleteAuthorizable= http://localhost:<%= port %><%= path %>/<%= user %>'
  },
  :add_user => {
    :aem55 => 'curl -u <%= admin_user %>:<%= admin_password %> -FcreateUser= -FauthorizableId=<%= user %> -Frep:password=<%= password %> -Fmembership=<%= group %> http://localhost:<%= port %>/libs/granite/security/post/authorizables'
  }
}
default[:aem][:author] = {
  :default_context => "/opt/aem/author",
  :port => "4502",
  :runnable_jar => "aem-author-p4502.jar",
  :base_dir => "/opt/aem/author/crx-quickstart",
  :jvm_opts => {},
  :ldap => {
    :enabled => false,
    :options => {}
  },
  :validation_urls => [
    "http://localhost:4502/libs/cq/core/content/login.html",
    "http://localhost:4502/damadmin",
    "http://localhost:4502/miscadmin",
    "http://localhost:4502/system/console/bundles"
  ],
  :deploy_pkgs => [
  #  { :name => "your package name here",
  #    :version => "your version here",
  #    :url => "url to download this package",
  #    :update => true or false - mostly useful for version "LATEST",
  #    :group_id => "the AEM group id for the package",
  #    :recursive => true or false - install embedded packages?,
  #    :properties_file => "path to file that contains the package version -
  #      if necessary
  #    :version_pattern => "regexp to find version" - version should be in first
  #      captured group.  This is a string; it will get converted to a regexp.
  #    :action => [ :upload, :install, :activate ]
  #  }
  ],
  #You changed these, right?
  :admin_user => "admin",
  :admin_password => "admin",
  :new_admin_password => nil,
  :replication_hosts => [
    #{ :ipaddress => "the IP or hostname where you want to replicate",
    #  :port => "the port of the publish server there",
    #  :user => "the admin user on the remote",
    #  :password => "the admin password on the remote"
    #}
  ],
  :find_replication_hosts_dynamically => false
}
default[:aem][:author][:startup][:max_attempts] = 20
default[:aem][:author][:startup][:wait_between_attempts] = 30

default[:aem][:publish] = {
  :default_context => "/opt/aem/publish",
  :port => "4503",
  :runnable_jar => "aem-publish-p4503.jar",
  :base_dir => "/opt/aem/publish/crx-quickstart",
  :jvm_opts => {},
  :ldap => {
    :enabled => false,
    :options => {}
  },
  :validation_urls => [
    "http://localhost:4503/libs/cq/core/content/login.html",
    "http://localhost:4503/damadmin",
    "http://localhost:4503/miscadmin",
    "http://localhost:4503/system/console/bundles"
  ],
  :deploy_pkgs => [
  # See the format in author, above
  ],
  :admin_user => "admin",
  :admin_password => "admin",
  :new_admin_password => nil,
  :cache_hosts => [
    #{ :ipaddress => "the IP or hostname of the caching dispatcher",
    #  :port => "the port of the http server there",
    #  :user => "the admin user on the remote",
    #  :password => "the admin password on the remote"
    #}
  ],
  :find_cache_hosts_dynamically => false
}
default[:aem][:publish][:startup][:max_attempts] = 20
default[:aem][:publish][:startup][:wait_between_attempts] = 30

#array of "n.n.n.n/n" subnets to allow connections from.  nil = all.
default[:aem][:dispatcher][:allow_connections] = nil
default[:aem][:dispatcher][:dynamic_cluster] = false
default[:aem][:dispatcher][:version] = nil
default[:aem][:dispatcher][:dispatcher_file_cookbook] = nil
default[:aem][:dispatcher][:webserver_type] = "apache2.2"
default[:aem][:dispatcher][:conf_file] = "conf/dispatcher.any"
default[:aem][:dispatcher][:log_file] = "logs/dispatcher.log"
default[:aem][:dispatcher][:log_level] = "1"
default[:aem][:dispatcher][:farm_dir] = "aem-farms"
default[:aem][:dispatcher][:farm_files] = [ "farm_*.any" ]
default[:aem][:dispatcher][:no_server_header] = "0"
default[:aem][:dispatcher][:decline_root] = "0"
default[:aem][:dispatcher][:use_processed_url] = "0"
default[:aem][:dispatcher][:pass_error] = "0"
default[:aem][:dispatcher][:farm_name] = nil
default[:aem][:dispatcher][:cache_root] = "/opt/communique/dispatcher/cache"
default[:aem][:dispatcher][:client_headers] = [ "*" ]
default[:aem][:dispatcher][:virtual_hosts] = [ "*" ]
default[:aem][:dispatcher][:renders] = [ { :name => "publish_rend", :hostname => "127.0.0.1",
                  :port => "4503", :timeout => "0" } ]
default[:aem][:dispatcher][:filter_rules] = {
    "0001" => '/type "deny"  /glob "*"',
    "0002" => '/type "deny"  /glob "GET *.*[0-9].json*"',
    "0041" => '/type "allow" /glob "* *.css *"',
    "0042" => '/type "allow" /glob "* *.gif *"',
    "0043" => '/type "allow" /glob "* *.ico *"',
    "0044" => '/type "allow" /glob "* *.js *"',
    "0045" => '/type "allow" /glob "* *.png *"',
    "0046" => '/type "allow" /glob "* *.swf *"',
    "0047" => '/type "allow" /glob "* *.jpg *"',
    "0061" => '/type "allow" /glob "POST /content/[.]*.form.html"',
    "0062" => '/type "allow" /glob "* /libs/cq/personalization/*"',
    "0081" => '/type "deny"  /glob "GET *.infinity.json*"',
    "0082" => '/type "deny"  /glob "GET *.tidy.json*"',
    "0083" => '/type "deny"  /glob "GET *.sysview.xml*"',
    "0084" => '/type "deny"  /glob "GET *.docview.json*"',
    "0085" => '/type "deny"  /glob "GET *.docview.xml*"',
    "0087" => '/type "deny"  /glob "GET *.feed.xml*"',
    "0090" => '/type "deny"  /glob "* *.query.json*"'
  }
default[:aem][:dispatcher][:cache_rules] = {
    "0000" => { :glob => "*", :type => "allow" }
  }
default[:aem][:dispatcher][:cache_opts] = []
default[:aem][:dispatcher][:invalidation_rules] = {
    "0000" => { :glob => "*", :type => "deny" },
    "0001" => { :glob => "*.html", :type => "allow" }
  }
default[:aem][:dispatcher][:allowed_clients] = {}
default[:aem][:dispatcher][:statistics] = [
    { :name => "html", :glob => "*.html" },
    { :name => "others", :glob => "*" },
  ]
default[:aem][:dispatcher][:site_name] = "00Dispatcher"
default[:aem][:dispatcher][:server_name] = node[:fqdn]
default[:aem][:dispatcher][:server_aliases] = []
default[:aem][:dispatcher][:aem_locations] = [ "/" ]
default[:aem][:dispatcher][:enabled] = true
default[:aem][:dispatcher][:rewrites] = []
default[:aem][:dispatcher][:listen_port] = "80"
default[:aem][:dispatcher][:ssl_enabled] = false
default[:aem][:dispatcher][:ssl_cert_file] = "/etc/httpd/ssl/server.crt"
default[:aem][:dispatcher][:ssl_key_file] = "/etc/httpd/ssl/server.key"
default[:aem][:dispatcher][:expire_dirs] = []
default[:aem][:dispatcher][:enable_etag] = false
default[:aem][:dispatcher][:enable_ie_header] = true
default[:aem][:dispatcher][:session_mgmt] = {
    "directory" => "#{node[:apache][:dir]}/dispatcher/sessions",
    "header" => "Cookie:login-token"
  }
default[:aem][:dispatcher][:enable_session_mgmt] = false
default[:aem][:dispatcher][:mod_dispatcher_url] = nil
default[:aem][:dispatcher][:mod_dispatcher_checksum] = nil
default[:aem][:dispatcher][:deflate_enabled] = true
default[:aem][:dispatcher][:header] = []