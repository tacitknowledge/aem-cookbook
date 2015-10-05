#2.2.0
* Enhancements
  * Add new group provider.
  * For AEM 6.1+, use group provider within user provider to add user to a group (if provided).

#2.1.0
* Refactor
  * Rubocop and other minor improvements

#2.0.0
* Refactor
  * Refactor node[:aem][:commands] and providers to allow commands for various AEM versions to be driven by attributes.
	
#1.1.17
* Enhancements
  * Allow cluster search to be more flexible. Defaults to existing role search, but allows for search via recipes/roles within a nodes run_list.
	
#1.1.16
* Fixes
  * Revert back to old mechanism of updating admin password, since the existing way does not converge on the first Chef run.
	
#1.1.15
* Fixes
  * Fix agent removal curl command.

#1.1.14
* Fixes
  * Fix the curl command for setting user password in AEM 5.6
	
# 1.1.13
* Enhancements
  * Add support for changing user passwords in AEM 5.6

#1.1.12
* Fixes
  * Modified apache_libexecdir dispatcher resource to support both new and old attribute name

# 1.1.11
* Enhancements
  * Add support for changing user passwords in AEM 6.1
  * Add AEM 6.1 test kitchen configuration

# 1.1.10
* Enhancements
  * Run and store admin password if new_admin_password is set and does not match the current admin password

# 1.1.9
* Enhancements
  * Fixed issue with curb gem failing to be included during compile time

# 1.1.8
* Enhancements
  * Mark license.properties file as sensitive
* Fixes
  * Fix deprecation warning for chef_gem

# 1.1.7
* Enhancements
  * Add support for Ignore URL Params for farm.any configuration template

# 1.1.6
* Enhancements
  * parameterized jar unpack path

# 1.1.5
* Enhancements
  * Adding support for Header derictive in Apache

# 1.1.4
* Fixes
  * fix for aem_jcr_node provider - check for 201 on node creation, check for content of binary instead of path

# 1.1.3
* Fixes
  * add support to change password in AEM6

# 1.1.2
* Fixes
  * replicator provider now creates cache flush agents
  * default dispatcher vhost now handles mime-types

# 1.1.1

* Fixes
  * Updated changelog.

# 1.1.0

* Enhancements
  * [#13](https://github.com/tacitknowledge/aem-cookbook/pull/13) Added aem_jcr_node provider.

# 1.0.3

* Enhancements
  * [#9](https://github.com/tacitknowledge/aem-cookbook/pull/9) Updated build dependencies.

# 1.0.2

* Fixes
  * [#7](https://github.com/tacitknowledge/aem-cookbook/pull/7) Update jar_installer provider to significantly reduce memory utilization.

# 1.0.1

* Enhancements
  * [#4](https://github.com/tacitknowledge/aem-cookbook/pull/4) Added support for AEM 6.0.0.

# 1.0.0

* Initial release to Github.
