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
        role_search = role.include?('[') ? %Q{run_list:"#{role}"} : %Q{role:"#{role}"}
        %Q(#{role_search} AND aem_cluster_name:"#{cluster_name}")
      end
    end
  end
end
