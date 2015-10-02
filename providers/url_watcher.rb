#
# Cookbook Name:: aem
# Provider:: url_watcher
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

# This provider creates a resource that monitors an httpd url, blocking until
# the url loads correctly, the service that is supposed to serve the url has
# died, or the timeout expires.
action :wait do
  wait_between_attempts = new_resource.wait_between_attempts
  validation_url = new_resource.validation_url
  max_attempts = new_resource.max_attempts
  creds = ''
  status_cmd =
    "if ! #{new_resource.status_command}; then " \
      "echo 'Service has died'; exit 1; fi"
  if new_resource.user && new_resource.password
    creds = "-u #{new_resource.user}:#{new_resource.password}"
  end
  if new_resource.match_string
    curl_validation_command = %(curl #{creds} --silent #{validation_url} | grep "#{new_resource.match_string}")
  else
    curl_validation_command = "curl #{creds} -o /dev/null --silent --head --write-out '%{http_code}' #{validation_url} | grep 200"
  end

  bash "wait for URL: #{validation_url}" do
    code <<-EOH
      #{status_cmd}
      ATTEMPTS=0
      while ! #{curl_validation_command} ; do

        echo "Waiting for URL..."
        sleep #{wait_between_attempts}
        #{status_cmd}
        ATTEMPTS=$(expr ${ATTEMPTS} + 1)

        if [ ${ATTEMPTS} -gt #{max_attempts} ] ; then
          echo "Max attempts reached... exiting with failure status."
          exit 100
        fi
      done
    EOH
  end
end
