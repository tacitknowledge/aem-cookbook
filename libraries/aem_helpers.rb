#
# Cookbook Name:: aem
# Library:: helpers
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

class AEM
  module Helpers
    class << self
      # Builds a portion of the search criteria for finding related AEM nodes in Chef server.
      #
      # The old way required a role, and assumed a search criteria that started with "role:#{role}".
      # This now also supports role with a value of "role[<role_name>]" or "recipe[recipe_name]" as
      # well. Chef requires the brackets to be escaped with a backslash, but that's not required
      # in the parameter (this module takes care of that).
      def build_cluster_search_criteria(role_name, cluster_name)
        # If role_name contains brackets, escape them (Chef server search requires this):
        # role == 'role[dispatcher]' will get converted to 'role\[dispatcher\]'
        # Values without brackets will remain unchanged.
        # For future reference, lucene has the following special characters (which all must be escaped):
        # + - && || ! ( ) { } [ ] ^ " ~ * ? : \
        # See http://lucene.apache.org/core/2_9_4/queryparsersyntax.html#Escaping Special Characters
        role = role_name.gsub(/\[(.*)\]/, '\[\1\]').gsub(/:/, '\:')
        role_search = role.include?('[') ? %(run_list:"#{role}") : %(role:"#{role}")
        %(#{role_search} AND aem_cluster_name:"#{cluster_name}")
      end

      # This method will return the command that corresponds to the closest matching version number as long as a
      # command exists with a version that is at least lower than the passed running_aem_version.
      #
      # commands should end up being a hash containing a 1:1 list of version => command
      # See node[:aem][:commands] in attributes/default.rb.
      def retrieve_command_for_version(commands, running_aem_version)
        current_aem_version = Gem::Version.new(running_aem_version)
        Chef::Log.info("Finding correct command for provided version: [#{running_aem_version}]")

        matching_version = nil
        matching_command = nil
        commands.each do |version, command|
          potential_version = Gem::Version.new(version)
          if current_aem_version >= potential_version && (matching_version.nil? || potential_version > matching_version)
            matching_version = potential_version
            matching_command = command
          end
        end
        Chef::Log.info("Closest matching version: [#{matching_version}], command: [#{matching_command}]")

        matching_command
      end
    end
  end
end
