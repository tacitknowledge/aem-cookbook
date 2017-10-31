#
# Cookbook Name:: aem
# Provider:: replicator
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

# This provider adds or removes replication agents from an AEM instance

require 'erb'

action :add do
  hosts = new_resource.remote_hosts
  local_user = new_resource.local_user
  local_password = new_resource.local_password
  local_port = new_resource.local_port
  role = new_resource.cluster_role
  cluster_name = new_resource.cluster_name
  type = new_resource.type
  server = new_resource.server || 'author'
  aem_version = new_resource.aem_version

  fail "No command specified for replicator type: #{type}. See node attribute :aem->" \
    ':commands->:replicators.' unless node[:aem][:commands][:replicators][type][:add]

  case type
  when :publish
    agent = aem_instance = :publish
  when :flush
    aem_instance = :dispatcher
    agent = 'flush'
    # these are usually on publishers
    server = new_resource.server || 'publish'
  when :flush_agent
    aem_instance = :dispatcher
    agent = 'flush'
    # these are usually on publishers
    server = new_resource.server || 'publish'
  when :agent
    agent = aem_instance = :publish
  end

  hosts.each_with_index do |h, counter|
    instance = counter > 0 ? counter.to_s : ''
    # Convergency for agent creation
    if agent_exist?(agent, instance, h, local_user, local_password, local_port  )
      Chef::Log.error("Agent exists. Skipping...")
    else
      if h[:agent_id].nil?
        log "No agent id found, don't populate the userId value for the replication agent"
        agent_id_param = ''
      else
        log "Agent id found #{h[:agent_id]}, populate the userId value for the replication agent with it"
        agent_id_param = "-F \"jcr:content/userId=#{h[:agent_id]}\""
      end

      aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:replicators][type][:add], aem_version)
      cmd = ERB.new(aem_command).result(binding)

      log "Adding replication agent with command: #{cmd}"
      runner = Mixlib::ShellOut.new(cmd)
      runner.run_command
      runner.error!
    end
  end
end

action :remove do
  hosts = new_resource.remote_hosts
  local_user = new_resource.local_user
  local_password = new_resource.local_password
  local_port = new_resource.local_port
  role = new_resource.cluster_role
  cluster_name = new_resource.cluster_name
  type = new_resource.type
  server = new_resource.server || 'author'
  aem_version = new_resource.aem_version

  fail "No command specified for replicator type: #{type}. See node attribute :aem->" \
    ':commands->:replicators.' unless node[:aem][:commands][:replicators][type][:remove]

  case type
  when :publish
    aem_instance = :publish
    agent = 'publish'
  when :flush
    aem_instance = :dispatcher
    agent = 'flush'
    server = new_resource.server || 'publish'
  when :flush_agent
    aem_instance = :dispatcher
    agent = 'flush'
    server = new_resource.server || 'publish'
  when :agent
    aem_instance = :publish
    agent = 'author'
  end

  counter = 0
  hosts.each do |h|
    instance = counter > 0 ? counter.to_s : ''

    aem_command = AEM::Helpers.retrieve_command_for_version(node[:aem][:commands][:replicators][type][:remove], aem_version)
    cmd = ERB.new(aem_command).result(binding)

    log "Removing replication agent with command: #{cmd}"
    runner = Mixlib::ShellOut.new(cmd)
    runner.run_command
    runner.error!
    counter += 1
  end
end

private
# Convergency for agent creation
def agent_exist?(agent, index, host, user, password, port)
  # Set commands per agent type
  case agent
  when 'flush'
    instance_type = 'publish'
    ip_regex = /Replication test to http:\/\/([a-zA-Z0-9\.\-]+)\/dispatcher\/invalidate.cache/
  when :publish
    instance_type = 'author'
    ip_regex = /Replication test to http:\/\/([a-zA-Z0-9\.\-]+):4503\/bin\/receive\?sling:authRequestLogin=1/
  end
  # Compose command
  # TODO: rewrite using command_finder
  command = "curl -u #{user}:#{password} -X GET http://localhost:#{port}/etc/replication/agents.#{instance_type}/#{agent.to_s}#{index}.test.html"

  # Run command
  runner = Mixlib::ShellOut.new(command)
  runner.run_command

  # If no errors and stdout recieved
  if !runner.error? && !runner.stdout.empty? && !runner.stdout.nil?
    # Extract ip check agent status from stdout
    ip_match = runner.stdout.match(ip_regex)
    ip = ip_match ? ip_match[1] : nil
    status = runner.stdout[/Replication test <strong>succeeded<\/strong>/]

    # If status success and ip detected
    if status && ip
      compare_ips(ip, host[:ipaddress])
    end
  else
    Chef::Log.error(" Command '#{command}'; runner.error?: '#{runner.error?}'; runner.stdout: '#{runner.stdout}'")
  end
end

# Compare if ip addresses are equal
def compare_ips(detected, requested)
  Chef::Log.warn(" Detected ip '#{detected}'; Requested ip:'#{requested}'")
  detected == requested
end
