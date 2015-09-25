#
# Cookbook Name:: aem
# Provider:: port_watcher
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

# This provider creates a resource that monitors a network port, blocking until
# the port is listening, the service that is supposed to listen on the port has
# died, or the timeout expires.

action :wait do
  timeout = new_resource.timeout
  expire_time = timeout ? Time.now.to_i + timeout : nil
  date_cmd = '' # do nothing if timeout is nil
  expire_time && date_cmd =
    "if [ \`date +%s\` -gt #{expire_time} ]; then " \
      "echo 'Timeout exceeded'; exit 2; fi"
  status_cmd =
    "if ! #{new_resource.status_command}; then " \
      "echo 'Service has died'; exit 1; fi"
  netstat_opts = new_resource.protocol == 'udp' ? '-uln' : '-tln'

  bash 'wait_for_port' do
    user 'root'
    code <<-EOH
      while ! netstat #{netstat_opts} | grep ":#{new_resource.port} "
        do
        #{status_cmd}
        #{date_cmd}
        sleep 10
      done
    EOH
  end
end
